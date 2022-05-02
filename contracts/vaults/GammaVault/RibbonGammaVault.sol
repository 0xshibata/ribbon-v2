// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {
    ReentrancyGuardUpgradeable
} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {
    OwnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    ERC20Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import {
    RibbonGammaVaultStorage
} from "../../storage/RibbonGammaVaultStorage.sol";
import {Vault} from "../../libraries/Vault.sol";
import {VaultLifecycle} from "../../libraries/VaultLifecycle.sol";
import {VaultLifecycleGamma} from "../../libraries/VaultLifecycleGamma.sol";
import {VaultLifecycleYearn} from "../../libraries/VaultLifecycleYearn.sol";
import {IYearnRegistry, IYearnVault} from "../../interfaces/IYearn.sol";
import {UniswapRouter} from "../../libraries/UniswapRouter.sol";
import {ShareMath} from "../../libraries/ShareMath.sol";
import {ILiquidityGauge} from "../../interfaces/ILiquidityGauge.sol";
import {IWETH} from "../../interfaces/IWETH.sol";
import {IERC20Detailed} from "../../interfaces/IERC20Detailed.sol";
import {
    IPowerPerpController,
    IOracle
} from "../../interfaces/PowerTokenInterface.sol";
import {
    IOptionsPurchaseQueue
} from "../../interfaces/IOptionsPurchaseQueue.sol";

/**
 * UPGRADEABILITY: Since we use the upgradeable proxy pattern, we must observe
 * the inheritance chain closely.
 * Any changes/appends in storage variable needs to happen in RibbonGammaVaultStorage.
 * RibbonGammaVault should not inherit from any other contract aside from RibbonVault, RibbonGammaVaultStorage
 */
contract RibbonGammaVault is
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    RibbonGammaVaultStorage
{
    using SafeERC20 for IERC20;
    using ShareMath for Vault.DepositReceipt;

    /************************************************
     *  IMMUTABLES & CONSTANTS
     ***********************************************/

    /// @notice WETH9 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    address public immutable WETH;

    /// @notice USDC 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public immutable USDC;

    /// @notice 7 day period between each options sale.
    uint256 public constant PERIOD = 7 days;

    /// @notice The collateral ratio targeted by the vault (200%)
    uint256 public constant COLLATERAL_RATIO = 2e18;

    /// @notice Withdrawal buffer for yearn vault
    uint256 public constant YEARN_WITHDRAWAL_BUFFER = 5; // 0.05%

    /// @notice Slippage incurred during withdrawal
    uint256 public constant YEARN_WITHDRAWAL_SLIPPAGE = 5; // 0.05%

    // Number of weeks per year = 52.142857 weeks * FEE_MULTIPLIER = 52142857
    // Dividing by weeks per year requires doing num.mul(FEE_MULTIPLIER).div(WEEKS_PER_YEAR)
    uint256 private constant WEEKS_PER_YEAR = 52142857;

    // CONTROLLER is the controller contract for interacting with Squeeth
    // https://github.com/opynfinance/squeeth-monorepo/blob/main/packages/hardhat/contracts/core/Controller.sol
    address public immutable CONTROLLER;

    // oSQTH token
    // https://github.com/opynfinance/squeeth-monorepo/blob/main/packages/hardhat/contracts/core/WPowerPerp.sol
    address public immutable SQTH;

    // Squeeth Oracle
    address public immutable ORACLE;

    // Squeeth short position vault ID
    uint256 public immutable VAULT_ID;

    // UNISWAP_ROUTER is the contract address of Uniswap V3 Router which handles swaps
    // https://github.com/Uniswap/v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol
    address public immutable UNISWAP_ROUTER;

    // UNISWAP_FACTORY is the contract address of Uniswap V3 Factory which stores pool information
    // https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol
    address public immutable UNISWAP_FACTORY;

    // USDC/WETH Uniswap V3 Pool
    address public immutable USDC_WETH_POOL;

    // oSQTH/WETH Uniswap V3 Pool
    address public immutable SQTH_WETH_POOL;

    // THETA_CALL_VAULT is Ribbon ETH Call Theta Vault to buy call options from
    address public immutable THETA_CALL_VAULT;

    // THETA_PUT_VAULT is Ribbon ETH Put Theta Vault to buy put options from
    address public immutable THETA_PUT_VAULT;

    // GAMMA_CONTROLLER is the contract address for opyn actions
    address public immutable GAMMA_CONTROLLER;

    // Yearn registry contract
    address public immutable YEARN_REGISTRY;

    /************************************************
     *  EVENTS
     ***********************************************/

    event Deposit(address indexed account, uint256 amount, uint256 round);

    event InitiateWithdraw(
        address indexed account,
        uint256 shares,
        uint256 round
    );

    event Redeem(address indexed account, uint256 share, uint256 round);

    event ManagementFeeSet(uint256 managementFee, uint256 newManagementFee);

    event PerformanceFeeSet(uint256 performanceFee, uint256 newPerformanceFee);

    event CapSet(uint256 oldCap, uint256 newCap);

    event OptionsPurchaseQueueSet(
        address oldOptionsPurchaseQueue,
        address newOptionsPurchaseQueue
    );

    event RatioThresholdSet(
        uint256 oldRatioThreshold,
        uint256 newRatioThreshold
    );

    event OptionAllocationSet(
        uint256 oldOptionAllocation,
        uint256 newOptionAllocation
    );

    event UsdcWethSwapPathSet(
        bytes oldUsdcWethSwapPath,
        bytes newUsdcWethSwapPath
    );

    event WethUsdcSwapPathSet(
        bytes oldWethUsdcSwapPath,
        bytes newWethUsdcSwapPath
    );

    event OptionPurchaseRequested(
        address callOtokens,
        address putOtokens,
        uint256 optionsQuantity
    );

    event Withdraw(address indexed account, uint256 amount, uint256 shares);

    event CollectVaultFees(
        uint256 performanceFee,
        uint256 vaultFee,
        uint256 round,
        address indexed feeRecipient
    );

    event InstantWithdraw(
        address indexed account,
        uint256 amount,
        uint256 round
    );

    /************************************************
     *  CONSTRUCTOR & INITIALIZATION
     ***********************************************/

    /**
     * @notice Initializes the contract with immutable variables
     * @param _weth is the Wrapped Ether contract
     * @param _usdc is the USDC contract
     * @param _squeethController is the contract address for Squeeth actions
     * @param _oracle is the Oracle contract used by the Squeeth controller
     * @param _uniswapRouter is the contract address for Uniswap V3 router which handles swaps
     * @param _uniswapFactory is the contract address for Uniswap V3 factory
     * @param _usdcWethPool is the USDC/WETH Uniswap V3 pool
     * @param _sqthWethPool is the oSQTH/WETH Uniswap V3 pool
     * @param _thetaCallVault is Ribbon ETH Call Theta Vault to buy call options from
     * @param _thetaPutVault is Ribbon ETH Put Theta Vault to buy put options from
     * @param _gammaController is the contract address for opyn actions
     */
    constructor(
        address _weth,
        address _usdc,
        address _squeethController,
        address _oracle,
        address _uniswapRouter,
        address _uniswapFactory,
        address _usdcWethPool,
        address _sqthWethPool,
        address _thetaCallVault,
        address _thetaPutVault,
        address _gammaController,
        address _yearnRegistry
    ) {
        require(_weth != address(0), "!_weth");
        require(_usdc != address(0), "!_usdc");
        require(_squeethController != address(0), "!_squeethController");
        require(_oracle != address(0), "!_oracle");
        require(_uniswapRouter != address(0), "!_uniswapRouter");
        require(_uniswapFactory != address(0), "!_uniswapFactory");
        require(_usdcWethPool != address(0), "!_usdcWethPool");
        require(_sqthWethPool != address(0), "!_sqthWethPool");
        require(_thetaCallVault != address(0), "!_thetaCallVault");
        require(_thetaPutVault != address(0), "!_thetaPutVault");
        require(_gammaController != address(0), "!_gammaController");
        require(_yearnRegistry != address(0), "!_yearnRegistry");

        USDC = _usdc;
        WETH = _weth;

        CONTROLLER = _squeethController;
        address _sqth =
            address(IPowerPerpController(_squeethController).wPowerPerp());
        SQTH = _sqth;
        ORACLE = _oracle;
        // Creates a vault for this contract and saves the vault ID
        VAULT_ID = IPowerPerpController(_squeethController)
            .mintWPowerPerpAmount(0, 0, 0);

        UNISWAP_ROUTER = _uniswapRouter;
        UNISWAP_FACTORY = _uniswapFactory;
        USDC_WETH_POOL = _usdcWethPool;
        SQTH_WETH_POOL = _sqthWethPool;
        THETA_CALL_VAULT = _thetaCallVault;
        THETA_PUT_VAULT = _thetaPutVault;
        GAMMA_CONTROLLER = _gammaController;
        YEARN_REGISTRY = _yearnRegistry;
    }

    /**
     * @notice Initializes the RibbonGammaVault contract with storage variables.
     * @param _initParams is the struct with vault initialization parameters
     * @param _vaultParams is the struct with vault general data
     */
    function initialize(
        VaultLifecycleGamma.InitParams calldata _initParams,
        Vault.VaultParams memory _vaultParams
    ) external initializer {
        _vaultParams.isPut = false;
        _vaultParams.decimals = IERC20Detailed(USDC).decimals();
        _vaultParams.asset = USDC;
        _vaultParams.underlying = WETH;

        VaultLifecycleGamma.verifyInitializerParams(
            USDC,
            WETH,
            UNISWAP_FACTORY,
            _initParams,
            _vaultParams
        );

        __ReentrancyGuard_init();
        __ERC20_init(_initParams._tokenName, _initParams._tokenSymbol);
        __Ownable_init();
        transferOwnership(_initParams._owner);

        keeper = _initParams._keeper;

        feeRecipient = _initParams._feeRecipient;
        performanceFee = _initParams._performanceFee;
        managementFee =
            (_initParams._managementFee * Vault.FEE_MULTIPLIER) /
            WEEKS_PER_YEAR;
        vaultParams = _vaultParams;

        uint256 assetBalance =
            IERC20(vaultParams.asset).balanceOf(address(this));
        ShareMath.assertUint104(assetBalance);
        vaultState.lastLockedAmount = uint104(assetBalance);

        vaultState.round = 1;

        optionsPurchaseQueue = _initParams._optionsPurchaseQueue;
        ratioThreshold = _initParams._ratioThreshold;
        optionAllocation = _initParams._optionAllocation;
        usdcWethSwapPath = _initParams._usdcWethSwapPath;
        wethUsdcSwapPath = _initParams._wethUsdcSwapPath;

        address collateralToken =
            IYearnRegistry(YEARN_REGISTRY).latestVault(vaultParams.asset);
        require(collateralToken != address(0), "!collateralToken");
    }

    /************************************************
     *  MODIFIERS
     ***********************************************/

    /**
     * @dev Throws if called by any account other than the keeper.
     */
    modifier onlyKeeper() {
        require(msg.sender == keeper, "!keeper");
        _;
    }

    /**
     * @dev Throws if called when new round not in progress.
     */
    modifier isClosingRound() {
        require(newRoundInProgress, "!newRoundInProgress");
        _;
    }

    /**
     * @dev Throws if called when new round is in progress.
     */
    modifier notClosingRound() {
        require(!newRoundInProgress, "!newRoundInProgress");
        _;
    }

    /************************************************
     *  SETTERS
     ***********************************************/

    /**
     * @notice Sets the new keeper
     * @param newKeeper is the address of the new keeper
     */
    function setNewKeeper(address newKeeper) external onlyOwner {
        require(newKeeper != address(0), "!newKeeper");
        keeper = newKeeper;
    }

    /**
     * @notice Sets the new fee recipient
     * @param newFeeRecipient is the address of the new fee recipient
     */
    function setFeeRecipient(address newFeeRecipient) external onlyOwner {
        require(newFeeRecipient != address(0), "!newFeeRecipient");
        require(newFeeRecipient != feeRecipient, "Must be new feeRecipient");
        feeRecipient = newFeeRecipient;
    }

    /**
     * @notice Sets the management fee for the vault
     * @param newManagementFee is the management fee (6 decimals). ex: 2 * 10 ** 6 = 2%
     */
    function setManagementFee(uint256 newManagementFee) external onlyOwner {
        require(
            newManagementFee < 100 * Vault.FEE_MULTIPLIER,
            "Invalid management fee"
        );

        // We are dividing annualized management fee by num weeks in a year
        uint256 tmpManagementFee =
            (newManagementFee * Vault.FEE_MULTIPLIER) / WEEKS_PER_YEAR;

        emit ManagementFeeSet(managementFee, newManagementFee);

        managementFee = tmpManagementFee;
    }

    /**
     * @notice Sets the performance fee for the vault
     * @param newPerformanceFee is the performance fee (6 decimals). ex: 20 * 10 ** 6 = 20%
     */
    function setPerformanceFee(uint256 newPerformanceFee) external onlyOwner {
        require(
            newPerformanceFee < 100 * Vault.FEE_MULTIPLIER,
            "Invalid performance fee"
        );

        emit PerformanceFeeSet(performanceFee, newPerformanceFee);

        performanceFee = newPerformanceFee;
    }

    /**
     * @notice Sets a new cap for deposits
     * @param newCap is the new cap for deposits
     */
    function setCap(uint256 newCap) external onlyOwner {
        require(newCap > 0, "!newCap");
        ShareMath.assertUint104(newCap);
        emit CapSet(vaultParams.cap, newCap);
        vaultParams.cap = uint104(newCap);
    }

    /**
     * @notice Sets the new liquidityGauge contract for this vault
     * @param newLiquidityGauge is the address of the new liquidityGauge contract
     */
    function setLiquidityGauge(address newLiquidityGauge) external onlyOwner {
        liquidityGauge = newLiquidityGauge;
    }

    /**
     * @notice Sets the new options purchase queue address
     * @param newOptionsPurchaseQueue is the new options purchase queue contract
     */
    function setOptionsPurchaseQueue(address newOptionsPurchaseQueue)
        external
        onlyOwner
    {
        require(
            newOptionsPurchaseQueue != address(0),
            "!newOptionsPurchaseQueue"
        );
        emit OptionsPurchaseQueueSet(
            optionsPurchaseQueue,
            newOptionsPurchaseQueue
        );
        optionsPurchaseQueue = newOptionsPurchaseQueue;
    }

    /**
     * @notice Sets the new ratioThreshold value for this vault
     * @param newRatioThreshold is the new ratioThreshold
     */
    function setRatioThreshold(uint256 newRatioThreshold) external onlyOwner {
        require(newRatioThreshold > 0, "!newRatioThreshold");
        emit RatioThresholdSet(ratioThreshold, newRatioThreshold);
        ratioThreshold = newRatioThreshold;
    }

    /**
     * @notice Sets the new optionAllocation value for this vault
     * @param newOptionAllocation is the new optionAllocation
     */
    function setOptionAllocation(uint256 newOptionAllocation)
        external
        onlyOwner
    {
        require(newOptionAllocation > 0, "!newOptionAllocation");
        emit OptionAllocationSet(optionAllocation, newOptionAllocation);
        optionAllocation = newOptionAllocation;
    }

    /**
     * @notice Sets the new USDC -> WETH swap path for this vault
     * @param newUsdcWethSwapPath is the new usdcWethSwapPath
     */
    function setUsdcWethSwapPath(bytes calldata newUsdcWethSwapPath)
        external
        onlyOwner
    {
        require(
            UniswapRouter.checkPath(
                newUsdcWethSwapPath,
                USDC,
                WETH,
                UNISWAP_FACTORY
            ),
            "!newUsdcWethSwapPath"
        );
        emit UsdcWethSwapPathSet(usdcWethSwapPath, newUsdcWethSwapPath);
        usdcWethSwapPath = newUsdcWethSwapPath;
    }

    /**
     * @notice Sets the new WETH -> USDC swap path for this vault
     * @param newWethUsdcSwapPath is the new wethUsdcSwapPath
     */
    function setWethUsdcSwapPath(bytes calldata newWethUsdcSwapPath)
        external
        onlyOwner
    {
        require(
            UniswapRouter.checkPath(
                newWethUsdcSwapPath,
                USDC,
                WETH,
                UNISWAP_FACTORY
            ),
            "!newWethUsdcSwapPath"
        );
        wethUsdcSwapPath = newWethUsdcSwapPath;
    }

    /************************************************
     *  DEPOSIT
     ***********************************************/

    /**
     * @notice Deposits the `asset` from msg.sender.
     * @param amount is the amount of `asset` to deposit
     */
    function deposit(uint256 amount) external notClosingRound nonReentrant {
        require(amount > 0, "!amount");

        _depositFor(amount, msg.sender);

        // An approve() by the msg.sender is required beforehand
        IERC20(USDC).safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice Deposits the `asset` from msg.sender added to `creditor`'s deposit.
     * @notice Used for vault -> vault deposits on the user's behalf
     * @param amount is the amount of `asset` to deposit
     * @param creditor is the address that can claim/withdraw deposited amount
     */
    function depositFor(uint256 amount, address creditor)
        external
        notClosingRound
        nonReentrant
    {
        require(amount > 0, "!amount");
        require(creditor != address(0));

        _depositFor(amount, creditor);

        // An approve() by the msg.sender is required beforehand
        IERC20(USDC).safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice Mints the vault shares to the creditor
     * @param amount is the amount of `asset` deposited
     * @param creditor is the address to receieve the deposit
     */
    function _depositFor(uint256 amount, address creditor) private {
        uint256 currentRound = vaultState.round;
        uint256 totalWithDepositedAmount = totalBalance() + amount;

        require(totalWithDepositedAmount <= vaultParams.cap, "Exceed cap");
        require(
            totalWithDepositedAmount >= vaultParams.minimumSupply,
            "Insufficient balance"
        );

        emit Deposit(creditor, amount, currentRound);

        Vault.DepositReceipt memory depositReceipt = depositReceipts[creditor];

        // If we have an unprocessed pending deposit from the previous rounds, we have to process it.
        uint256 unredeemedShares =
            depositReceipt.getSharesFromReceipt(
                currentRound,
                roundPricePerShare[depositReceipt.round],
                vaultParams.decimals
            );

        uint256 depositAmount = amount;

        // If we have a pending deposit in the current round, we add on to the pending deposit
        if (currentRound == depositReceipt.round) {
            uint256 newAmount = uint256(depositReceipt.amount) + amount;
            depositAmount = newAmount;
        }

        ShareMath.assertUint104(depositAmount);

        depositReceipts[creditor] = Vault.DepositReceipt({
            round: uint16(currentRound),
            amount: uint104(depositAmount),
            unredeemedShares: uint128(unredeemedShares)
        });

        uint256 newTotalPending = uint256(vaultState.totalPending) + amount;
        ShareMath.assertUint128(newTotalPending);

        vaultState.totalPending = uint128(newTotalPending);
    }

    /************************************************
     *  WITHDRAWALS
     ***********************************************/

    /**
     * @notice Initiates a withdrawal that can be processed once the round completes
     * @param numShares is the number of shares to withdraw
     */
    function initiateWithdraw(uint256 numShares)
        external
        notClosingRound
        nonReentrant
    {
        require(numShares > 0, "!numShares");

        // We do a max redeem before initiating a withdrawal
        // But we check if they must first have unredeemed shares
        if (
            depositReceipts[msg.sender].amount > 0 ||
            depositReceipts[msg.sender].unredeemedShares > 0
        ) {
            _redeem(0, true);
        }

        // This caches the `round` variable used in shareBalances
        uint256 currentRound = vaultState.round;
        Vault.Withdrawal storage withdrawal = withdrawals[msg.sender];

        bool withdrawalIsSameRound = withdrawal.round == currentRound;

        emit InitiateWithdraw(msg.sender, numShares, currentRound);

        uint256 existingShares = uint256(withdrawal.shares);

        uint256 withdrawalShares;
        if (withdrawalIsSameRound) {
            withdrawalShares = existingShares + numShares;
        } else {
            require(existingShares == 0, "Existing withdraw");
            withdrawalShares = numShares;
            withdrawals[msg.sender].round = uint16(currentRound);
        }

        ShareMath.assertUint128(withdrawalShares);
        withdrawals[msg.sender].shares = uint128(withdrawalShares);

        uint256 newQueuedWithdrawShares =
            uint256(vaultState.queuedWithdrawShares) + numShares;
        ShareMath.assertUint128(newQueuedWithdrawShares);
        vaultState.queuedWithdrawShares = uint128(newQueuedWithdrawShares);

        _transfer(msg.sender, address(this), numShares);
    }

    /**
     * @notice Completes a scheduled withdrawal from a past round. Uses finalized pps for the round
     */
    function completeWithdraw() external notClosingRound nonReentrant {
        Vault.Withdrawal storage withdrawal = withdrawals[msg.sender];

        uint256 withdrawalShares = withdrawal.shares;
        uint256 withdrawalRound = withdrawal.round;

        // This checks if there is a withdrawal
        require(withdrawalShares > 0, "Not initiated");

        require(withdrawalRound < vaultState.round, "Round not closed");

        // We leave the round number as non-zero to save on gas for subsequent writes
        withdrawals[msg.sender].shares = 0;
        vaultState.queuedWithdrawShares = uint128(
            uint256(vaultState.queuedWithdrawShares) - withdrawalShares
        );

        uint256 withdrawAmount =
            ShareMath.sharesToAsset(
                withdrawalShares,
                roundPricePerShare[withdrawalRound],
                vaultParams.decimals
            );

        emit Withdraw(msg.sender, withdrawAmount, withdrawalShares);

        _burn(address(this), withdrawalShares);

        require(withdrawAmount > 0, "!withdrawAmount");
        IERC20(USDC).safeTransfer(msg.sender, withdrawAmount);

        lastQueuedWithdrawAmount = uint128(
            uint256(lastQueuedWithdrawAmount) - withdrawAmount
        );
    }

    /**
     * @notice Withdraws the assets on the vault using the outstanding `DepositReceipt.amount`
     * @param amount is the amount to withdraw
     */
    function withdrawInstantly(uint256 amount)
        external
        notClosingRound
        nonReentrant
    {
        Vault.DepositReceipt storage depositReceipt =
            depositReceipts[msg.sender];

        uint256 currentRound = vaultState.round;
        require(amount > 0, "!amount");
        require(depositReceipt.round == currentRound, "Invalid round");

        uint256 receiptAmount = depositReceipt.amount;
        require(receiptAmount >= amount, "Exceed amount");

        // Subtraction underflow checks already ensure it is smaller than uint104
        depositReceipt.amount = uint104(receiptAmount - amount);
        vaultState.totalPending = uint128(
            uint256(vaultState.totalPending) - amount
        );

        emit InstantWithdraw(msg.sender, amount, currentRound);

        IERC20(USDC).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Redeems shares that are owed to the account
     * @param numShares is the number of shares to redeem
     */
    function redeem(uint256 numShares) external nonReentrant {
        require(numShares > 0, "!numShares");
        _redeem(numShares, false);
    }

    /**
     * @notice Redeems the entire unredeemedShares balance that is owed to the account
     */
    function maxRedeem() external nonReentrant {
        _redeem(0, true);
    }

    /**
     * @notice Redeems shares that are owed to the account
     * @param numShares is the number of shares to redeem, could be 0 when isMax=true
     * @param isMax is flag for when callers do a max redemption
     */
    function _redeem(uint256 numShares, bool isMax) internal {
        Vault.DepositReceipt memory depositReceipt =
            depositReceipts[msg.sender];

        // This handles the null case when depositReceipt.round = 0
        // Because we start with round = 1 at `initialize`
        uint256 currentRound = vaultState.round;

        uint256 unredeemedShares =
            depositReceipt.getSharesFromReceipt(
                currentRound,
                roundPricePerShare[depositReceipt.round],
                vaultParams.decimals
            );

        numShares = isMax ? unredeemedShares : numShares;
        if (numShares == 0) {
            return;
        }
        require(numShares <= unredeemedShares, "Exceeds available");

        // If we have a depositReceipt on the same round, BUT we have some unredeemed shares
        // we debit from the unredeemedShares, but leave the amount field intact
        // If the round has past, with no new deposits, we just zero it out for new deposits.
        if (depositReceipt.round < currentRound) {
            depositReceipts[msg.sender].amount = 0;
        }

        ShareMath.assertUint128(numShares);
        depositReceipts[msg.sender].unredeemedShares = uint128(
            unredeemedShares - numShares
        );

        emit Redeem(msg.sender, numShares, depositReceipt.round);

        _transfer(address(this), msg.sender, numShares);
    }

    /************************************************
     *  STAKING
     ***********************************************/

    /**
     * @notice Stakes a users vault shares
     * @param numShares is the number of shares to stake
     */
    function stake(uint256 numShares) external nonReentrant {
        address _liquidityGauge = liquidityGauge;
        require(_liquidityGauge != address(0)); // Removed revert msgs due to contract size limit
        require(numShares > 0);
        uint256 heldByAccount = balanceOf(msg.sender);
        if (heldByAccount < numShares) {
            _redeem(numShares - heldByAccount, false);
        }
        _transfer(msg.sender, address(this), numShares);
        _approve(address(this), _liquidityGauge, numShares);
        ILiquidityGauge(_liquidityGauge).deposit(numShares, msg.sender, false);
    }

    /************************************************
     *  VAULT ROUTINES
     ***********************************************/

    /**
     * @notice Mints vault shares for new depositors
     */
    function closeCurrentRound() external onlyKeeper nonReentrant {
        // Exercise the options if there are tokens bought from last week
        if (callOtokens != address(0)) {
            VaultLifecycle.settleLong(GAMMA_CONTROLLER, callOtokens, WETH);
        }

        if (putOtokens != address(0)) {
            uint256 earnedAmount =
                VaultLifecycle.settleLong(GAMMA_CONTROLLER, putOtokens, USDC);
            VaultLifecycleYearn.unwrapYieldToken(
                earnedAmount,
                USDC,
                collateralToken,
                YEARN_WITHDRAWAL_BUFFER,
                YEARN_WITHDRAWAL_SLIPPAGE
            );
        }

        // Update vault states and calculate fees
        vaultState.lastLockedAmount = uint104(vaultState.lockedAmount);
        vaultState.lockedAmount = 0;

        address recipient = feeRecipient;
        uint256 lockedBalance;
        uint256 queuedWithdrawAmount;
        uint256 mintShares;
        uint256 performanceFeeInAsset;
        uint256 totalVaultFee;
        {
            uint256 newPricePerShare;
            (
                lockedBalance,
                queuedWithdrawAmount,
                newPricePerShare,
                mintShares,
                performanceFeeInAsset,
                totalVaultFee
            ) = VaultLifecycle.rollover(
                vaultState,
                VaultLifecycle.RolloverParams(
                    vaultParams.decimals,
                    totalBalance(),
                    totalSupply(),
                    lastQueuedWithdrawAmount,
                    performanceFee,
                    managementFee
                )
            );

            uint256 currentRound = vaultState.round;
            roundPricePerShare[currentRound] = newPricePerShare;

            emit CollectVaultFees(
                performanceFeeInAsset,
                totalVaultFee,
                currentRound,
                recipient
            );

            pendingDeposits = vaultState.totalPending;

            vaultState.totalPending = 0;
            vaultState.round = uint16(currentRound + 1);
        }

        _mint(address(this), mintShares);

        if (totalVaultFee > 0) {
            IERC20(USDC).safeTransfer(recipient, totalVaultFee);
        }

        lastQueuedWithdrawAmount = queuedWithdrawAmount;

        ShareMath.assertUint104(lockedBalance);
        vaultState.lockedAmount = uint104(lockedBalance);

        newRoundInProgress = true;
    }

    // /**
    //  * @notice View function to get necessary params to run prepareReadyState function
    //  * @dev This function is for view purposes only. It's gas inefficient and should not be called on-chain
    //  */
    // function getReadyStateParams()
    //     public
    //     view
    //     returns (
    //         uint256 wethBalanceShortage,
    //         uint256 usdcBalanceShortage,
    //         uint256 usdcBalanceShortageInWETH
    //     )
    // {
    //     return
    //         VaultLifecycleGamma.getReadyStateParams(
    //             VaultLifecycleGamma.ReadyParams(
    //                 CONTROLLER,
    //                 ORACLE,
    //                 SQTH_WETH_POOL,
    //                 USDC_WETH_POOL,
    //                 SQTH,
    //                 WETH,
    //                 USDC,
    //                 VAULT_ID,
    //                 optionsPurchaseQueue,
    //                 THETA_CALL_VAULT,
    //                 THETA_PUT_VAULT,
    //                 optionAllocation,
    //                 lastQueuedWithdrawAmount
    //             )
    //         );
    // }

    /**
     * @notice Prepare balance to queue for purchase
     * @dev To run this function, keeper is suggested to get the params from getReadyStateParams
     * @param wethBalanceShortage is the amount of WETH shortage to get the vault ready
     * @param usdcBalanceShortage is the amount of USDC shortage to get the vault ready
     * @param usdcBalanceShortageInWETH is the amount of USDC shortage to get the vault ready in WETH terms
     */
    function prepareReadyState(
        uint256 wethBalanceShortage,
        uint256 usdcBalanceShortage,
        uint256 usdcBalanceShortageInWETH
    ) external onlyKeeper isClosingRound nonReentrant returns (uint256 amountIn) {
        uint256 wethAmount = wethBalanceShortage + usdcBalanceShortageInWETH;

        // Need this function to maintain collateral ratio
        IPowerPerpController(CONTROLLER).burnWPowerPerpAmount(
            VAULT_ID,
            wethAmount,
            0
        );

        IWETH(WETH).deposit{value: wethAmount}();

        return VaultLifecycleGamma.swapExactOutput(
            WETH,
            usdcBalanceShortage,
            usdcBalanceShortageInWETH,
            UNISWAP_ROUTER,
            wethUsdcSwapPath
        );
    }

    /**
     * @notice Place purchase of options in the queue and start a new round
     */
    function startNextRound() external onlyKeeper isClosingRound nonReentrant {
        uint256 optionsQuantity;

        (callOtokens, putOtokens, optionsQuantity) = VaultLifecycleGamma
            .requestPurchase(
            CONTROLLER,
            ORACLE,
            SQTH_WETH_POOL,
            SQTH,
            WETH,
            USDC,
            VAULT_ID,
            optionsPurchaseQueue,
            THETA_CALL_VAULT,
            THETA_PUT_VAULT,
            optionAllocation
        );

        if (callOtokens != address(0) || putOtokens != address(0)) {
            emit OptionPurchaseRequested(
                callOtokens,
                putOtokens,
                optionsQuantity
            );
        }

        // Ensure there is sufficient balance for users to withdraw
        require(
            IERC20(USDC).balanceOf(address(this)) == lastQueuedWithdrawAmount
        );

        newRoundInProgress = false;
    }

    /**
     * @notice Allocate leftover WETH and USDC balance to Squeeth,
     * this should be used to allocate the leftover premiums from options purchase queue
     * @param minWethAmountOut is the minimum amount of WETH acceptable when swapping the USDC balance
     */
    function allocateLeftoverBalance(uint256 minWethAmountOut)
        external
        onlyKeeper
        nonReentrant
    {
        uint256 currentWethBalance = IERC20(WETH).balanceOf(address(this));
        uint256 currentUsdcBalance =
            IERC20(USDC).balanceOf(address(this)) -
                lastQueuedWithdrawAmount -
                vaultState.totalPending;
        require(currentWethBalance != 0 || currentUsdcBalance != 0);

        if (currentUsdcBalance > 0) {
            uint256 wethReceived =
                VaultLifecycleGamma.swapExactInput(
                    USDC,
                    currentUsdcBalance,
                    minWethAmountOut,
                    UNISWAP_ROUTER,
                    usdcWethSwapPath
                );
        }

        // Deposit collateral into controller
    }

    /************************************************
     *  BALANCING FUNCTIONS
     ***********************************************/

    // /**
    //  * @notice Get rebalance status
    //  */
    // function getRebalanceStatus() public
    //     view returns (bool isAboveThreshold, uint256 sqthAmount){
    //     (isAboveThreshold, sqthAmount) =
    //     VaultLifecycleGamma.getRebalanceStatus(
    //         CONTROLLER,
    //         ORACLE,
    //         SQTH_WETH_POOL,
    //         SQTH,
    //         WETH,
    //         VAULT_ID,
    //         COLLATERAL_RATIO
    //     );
    // }

    /**
     * @notice Rebalance the vault's position
     */
    function rebalance(uint256 maxAmountIn) external onlyKeeper {
        (bool isAboveThreshold, uint256 sqthAmount) =
            VaultLifecycleGamma.getRebalanceStatus(
                CONTROLLER,
                ORACLE,
                SQTH_WETH_POOL,
                SQTH,
                WETH,
                VAULT_ID,
                COLLATERAL_RATIO
            );

        if (isAboveThreshold) {
            VaultLifecycleGamma.withdrawCollateral(
                WETH,
                SQTH,
                SQTH_WETH_POOL,
                sqthAmount,
                maxAmountIn,
                0
            );
        } else {
            // Mint SQTH
            IPowerPerpController(CONTROLLER).mintWPowerPerpAmount(
                VAULT_ID,
                sqthAmount,
                0
            );
        }
    }

    /************************************************
     *  UNISWAP CALLBACK OVERRIDE
     ***********************************************/

    /**
     * @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
     * @dev In the implementation you must pay the pool tokens owed for the swap.
     *  The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
     *  amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
     * @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
     *  the end of the swap. If positive, the callback must send that amount of token0 to the pool.
     * @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
     *  the end of the swap. If positive, the callback must send that amount of token1 to the pool.
     * @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
     */
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        require(msg.sender == SQTH_WETH_POOL, "!SQTH_WETH_POOL"); // Only allow callbacks from the oSQTH/WETH pool
        require(amount0Delta > 0 || amount1Delta > 0); // Swaps entirely within 0-liquidity regions are not supported

        // Determine the amount that needs to be repaid as part of the flash swap
        uint256 amountToPay =
            amount0Delta > 0 ? uint256(amount0Delta) : uint256(amount1Delta);

        VaultLifecycleGamma.handleCallback(
            CONTROLLER,
            WETH,
            SQTH,
            VAULT_ID,
            amountToPay,
            data
        );
    }

    /************************************************
     *  GETTERS
     ***********************************************/

    /**
     * @notice Returns the asset balance held on the vault for the account
     * @param account is the address to lookup balance for
     * @return the amount of `asset` custodied by the vault for the user
     */
    function accountVaultBalance(address account)
        external
        view
        returns (uint256)
    {
        uint256 _decimals = vaultParams.decimals;
        uint256 assetPerShare =
            ShareMath.pricePerShare(
                totalSupply(),
                totalBalance(),
                vaultState.totalPending,
                _decimals
            );
        return
            ShareMath.sharesToAsset(shares(account), assetPerShare, _decimals);
    }

    /**
     * @notice Getter for returning the account's share balance including unredeemed shares
     * @param account is the account to lookup share balance for
     * @return the share balance
     */
    function shares(address account) public view returns (uint256) {
        (uint256 heldByAccount, uint256 heldByVault) = shareBalances(account);
        return heldByAccount + heldByVault;
    }

    /**
     * @notice Getter for returning the account's share balance split between account and vault holdings
     * @param account is the account to lookup share balance for
     * @return heldByAccount is the shares held by account
     * @return heldByVault is the shares held on the vault (unredeemedShares)
     */
    function shareBalances(address account)
        public
        view
        returns (uint256 heldByAccount, uint256 heldByVault)
    {
        Vault.DepositReceipt memory depositReceipt = depositReceipts[account];

        if (depositReceipt.round < ShareMath.PLACEHOLDER_UINT) {
            return (balanceOf(account), 0);
        }

        uint256 unredeemedShares =
            depositReceipt.getSharesFromReceipt(
                vaultState.round,
                roundPricePerShare[depositReceipt.round],
                vaultParams.decimals
            );

        return (balanceOf(account), unredeemedShares);
    }

    /**
     * @notice The price of a unit of share denominated in the `asset`
     */
    function pricePerShare() external view returns (uint256) {
        return
            ShareMath.pricePerShare(
                totalSupply(),
                totalBalance(),
                vaultState.totalPending,
                vaultParams.decimals
            );
    }

    /**
     * @notice Returns the vault's total balance, including the amounts locked into a short position
     * @return total balance of the vault, including the amounts locked in third party protocols
     */
    function totalBalance() public view returns (uint256) {
        return
            VaultLifecycleGamma.getTotalBalance(
                CONTROLLER,
                ORACLE,
                USDC_WETH_POOL,
                SQTH_WETH_POOL,
                SQTH,
                WETH,
                USDC,
                VAULT_ID
            );
    }

    /**
     * @notice Returns the token decimals
     */
    function decimals() public view override returns (uint8) {
        return vaultParams.decimals;
    }

    /**
     * @notice Returns the vault cap
     */
    function cap() external view returns (uint256) {
        return vaultParams.cap;
    }

    /**
     * @notice Returns the total pending deposit
     */
    function totalPending() external view returns (uint256) {
        return vaultState.totalPending;
    }
}
