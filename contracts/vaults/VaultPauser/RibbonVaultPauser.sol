// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVaultPauser} from "../../interfaces/IVaultPauser.sol";
import {Vault} from "../../libraries/Vault.sol";
import {IRibbonThetaVault} from "../../interfaces/IRibbonThetaVault.sol";
import {IWETH} from "../../interfaces/IWETH.sol";
import {RibbonVault} from "../BaseVaults/base/RibbonVault.sol";
import {ShareMath} from "../../libraries/ShareMath.sol";

contract RibbonVaultPauser is Ownable, IVaultPauser {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    /************************************************
     *  NON UPGRADEABLE STORAGE
     ***********************************************/

    /// @notice Stores all the vault's paused positions
    struct PauseReceipt {
        uint16 round;
        address account;
        uint128 shares;
        bool paused;
    }

    mapping(address => mapping(address => PauseReceipt)) public pausedPositions;

    /************************************************
     *  IMMUTABLES & CONSTANTS
     ***********************************************/
    /// @notice WETH9 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    address public immutable WETH;
    address public immutable STETH;
    address public immutable STETH_VAULT;

    address public keeper;
    /************************************************
     *  EVENTS
     ***********************************************/

    event Pause(
        address indexed account,
        address indexed vaultAddress,
        uint256 share,
        uint256 round
    );

    event Resume(
        address indexed account,
        address indexed vaultAddress,
        uint256 withdrawAmount
    );

    event ProcessWithdrawal(address indexed vaultAddress, uint256 round);

    /************************************************
     *  CONSTRUCTOR & INITIALIZATION
     ***********************************************/

    /**
     * @notice Initializes the contract with immutable variables
     */
    constructor(
        address _keeper,
        address _weth,
        address _steth,
        address _steth_vault
    ) {
        require(_keeper != address(0), "!_keeper");
        require(_weth != address(0), "!_weth");
        require(_steth != address(0), "!_steth");
        require(_steth_vault != address(0), "!_steth_vault");

        keeper = _keeper;
        WETH = _weth;
        STETH = _steth;
        STETH_VAULT = _steth_vault;
    }

    /**
     * @dev Throws if called by any account other than the keeper.
     */
    modifier onlyKeeper() {
        require(msg.sender == keeper, "!keeper");
        _;
    }

    /************************************************
     *  GETTERS
     ***********************************************/

    function isPaused(address _vaultAddress, address _userAddress)
        external
        view
        override
        returns (bool paused)
    {
        return pausedPositions[_vaultAddress][_userAddress].paused;
    }

    function getPausePosition(address _vaultAddress, address _userAddress)
        external
        view
        returns (PauseReceipt memory)
    {
        return pausedPositions[_vaultAddress][_userAddress];
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

    /************************************************
     *  VAULT OPERATIONS
     ***********************************************/

    /**
     * @notice pause position from vault by redeem all the shares from vault to Pauser
     * @param _account user's address
     * @param _amount the amount of shares
     */
    function pausePosition(address _account, uint256 _amount)
        external
        override
    {
        address currentVaultAddress = address(msg.sender);
        IRibbonThetaVault currentVault = IRibbonThetaVault(currentVaultAddress);

        // check if position is paused
        require(
            !pausedPositions[currentVaultAddress][_account].paused,
            "Position is paused"
        );

        // transfer from user to pauser
        IERC20(currentVaultAddress).safeTransferFrom(
            _account,
            address(this),
            _amount
        );

        uint16 round = currentVault.vaultState().round;

        pausedPositions[currentVaultAddress][_account] = PauseReceipt({
            round: round,
            account: address(_account),
            shares: uint104(_amount),
            paused: true
        });

        emit Pause(_account, currentVaultAddress, _amount, round);

        currentVault.initiateWithdraw(_amount);
    }

    /**
     * @notice resume user's position into vault by making a deposit
     * @param _vaultAddress vault's address
     */
    function resumePosition(address _vaultAddress) external override {
        IRibbonThetaVault currentVault = IRibbonThetaVault(_vaultAddress);
        address currentUser = address(msg.sender);

        // get params and round
        Vault.VaultParams memory currentParams = currentVault.vaultParams();
        uint16 round = currentVault.vaultState().round;

        PauseReceipt memory pauseReceipts =
            pausedPositions[_vaultAddress][currentUser];

        // check if roun is closed before resuming position
        require(pauseReceipts.round < round, "Round not closed yet");
        uint256 totalWithdrawAmount =
            ShareMath.sharesToAsset(
                pauseReceipts.shares,
                currentVault.roundPricePerShare(uint256(pauseReceipts.round)),
                currentParams.decimals
            );

        // revert receipts back to none
        pausedPositions[_vaultAddress][currentUser] = PauseReceipt({
            round: 0,
            account: currentUser,
            shares: uint104(0),
            paused: false
        });

        // stETH transfers suffer from an off-by-1 error
        // since we received STETH , we shall deposit using STETH instead of ETH
        if (_vaultAddress == STETH_VAULT) {
            totalWithdrawAmount = totalWithdrawAmount.sub((3));

            emit Resume(currentUser, _vaultAddress, totalWithdrawAmount.sub(1));
            IERC20(STETH).approve(_vaultAddress, totalWithdrawAmount);
            currentVault.depositYieldToken(totalWithdrawAmount, currentUser);
            return;
        }

        emit Resume(currentUser, _vaultAddress, totalWithdrawAmount);

        // if asset is ETH, we will convert it into WETH before depositing
        if (currentParams.asset == WETH) {
            IWETH(WETH).deposit{value: totalWithdrawAmount}();
        }
        IERC20(currentParams.asset).approve(_vaultAddress, totalWithdrawAmount);

        currentVault.depositFor(totalWithdrawAmount, currentUser);
    }

    /**
     * @notice process withdrawals by completing in a batch
     * @param _vaultAddress vault's address to be processed
     */
    function processWithdrawal(address _vaultAddress) external onlyKeeper {
        IRibbonThetaVault currentVault = IRibbonThetaVault(_vaultAddress);
        // we can only process withdrawal after closing the previous round
        // hence round should be - 1
        emit ProcessWithdrawal(
            _vaultAddress,
            currentVault.vaultState().round - 1
        );
        currentVault.completeWithdraw();
    }

    fallback() external payable {}

    receive() external payable {}
}
