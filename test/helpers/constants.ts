// *
// Vault constants
//
export const PLACEHOLDER_ADDR = "0x0000000000000000000000000000000000000001";

/**
 * Assets
 */
export const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
export const WBTC_ADDRESS = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
export const USDC_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";

export const WBTC_OWNER_ADDRESS = "0xCA06411bd7a7296d7dbdd0050DFc846E95fEBEB7";
export const USDC_OWNER_ADDRESS = "0x47ac0fb4f2d84898e4d9e7b4dab3c24507a6d503";

/**
 * Gamma Protocol
 */
export const OTOKEN_FACTORY = "0x7C06792Af1632E77cb27a558Dc0885338F4Bdf8E";
export const MARGIN_POOL = "0x5934807cC0654d46755eBd2848840b616256C6Ef";
export const SWAP_CONTRACT = "0x4572f2554421Bd64Bef1c22c8a81840E8D496BeA";

export const GAMMA_ORACLE = "0xc497f40D1B7db6FA5017373f1a0Ec6d53126Da23";
export const GAMMA_WHITELIST = "0xa5EA18ac6865f315ff5dD9f1a7fb1d41A30a6779";
export const GAMMA_CONTROLLER = "0x4ccc2339F87F6c59c6893E1A678c2266cA58dC72";
export const ORACLE_OWNER = "0x638E5DA0EEbbA58c67567bcEb4Ab2dc8D34853FB";

export const ORACLE_DISPUTE_PERIOD = 7200;
export const ORACLE_LOCKING_PERIOD = 300;

/**
 * Gamma Pricers
 */
export const CHAINLINK_WETH_PRICER =
  "0xAC05f5147566Cc949b73F0A776944E7011FabC50";
export const CHAINLINK_WBTC_PRICER =
  "0x5faCA6DF39c897802d752DfCb8c02Ea6959245Fc";

/**
 * Gnosis Protocol
 */
export const GNOSIS_EASY_AUCTION = "0x0b7fFc1f4AD541A4Ed16b40D8c37f0929158D101";
export const BYTES_ZERO =
  "0x0000000000000000000000000000000000000000000000000000000000000000";

/**
 *  Rvol Addresses
 */

export const VOL_ORACLE = "0x4df938e57fD4Ad1dFDdDEEb1B4cFAbAB19E33A0E";

/**
 * RVol Bytecode
 */
export const OptionsPremiumPricer_BYTECODE =
  "0x61014060405234801561001157600080fd5b5060405162001643380380620016438339818101604052608081101561003657600080fd5b50805160208201516040830151606090930151919290916001600160a01b038416610091576040805162461bcd60e51b81526020600482015260066024820152650857dc1bdbdb60d21b604482015290519081900360640190fd5b6001600160a01b0383166100e1576040805162461bcd60e51b8152602060048201526012602482015271215f766f6c6174696c6974794f7261636c6560701b604482015290519081900360640190fd5b6001600160a01b03821661012c576040805162461bcd60e51b815260206004820152600d60248201526c215f70726963654f7261636c6560981b604482015290519081900360640190fd5b6001600160a01b038116610179576040805162461bcd60e51b815260206004820152600f60248201526e215f737461626c65734f7261636c6560881b604482015290519081900360640190fd5b6001600160601b0319606085811b821660805284811b821660a05283811b821660c05282901b1660e0526040805163313ce56760e01b815290516001600160a01b0384169163313ce567916004808301926020929190829003018186803b1580156101e357600080fd5b505afa1580156101f7573d6000803e3d6000fd5b505050506040513d602081101561020d57600080fd5b5051610100526040805163313ce56760e01b815290516001600160a01b0383169163313ce567916004808301926020929190829003018186803b15801561025357600080fd5b505afa158015610267573d6000803e3d6000fd5b505050506040513d602081101561027d57600080fd5b5051610120525050505060805160601c60a05160601c60c05160601c60e05160601c6101005161012051611343620003006000398061063e525080610618528061073f5250806103f352806106925250806101865280610202528061034552806105605250806103cf528061077c52508061016252806107ab52506113436000f3fe608060405234801561001057600080fd5b50600436106100885760003560e01c806355b13a4f1161005b57806355b13a4f146100f6578063562c9c57146100fe5780639380576f14610106578063fc3d42e81461013557610088565b806316f0115b1461008d5780632630c12f146100b1578063365cab0a146100b9578063468f02d2146100ee575b600080fd5b610095610160565b604080516001600160a01b039092168252519081900360200190f35b610095610184565b6100dc600480360360408110156100cf57600080fd5b50803590602001356101a8565b60408051918252519081900360200190f35b6100dc610341565b6100956103cd565b6100956103f1565b6100dc6004803603608081101561011c57600080fd5b5080359060208101359060408101359060600135610415565b6100dc6004803603606081101561014b57600080fd5b50803590602081013590604001351515610506565b7f000000000000000000000000000000000000000000000000000000000000000081565b7f000000000000000000000000000000000000000000000000000000000000000081565b60004282116101fe576040805162461bcd60e51b815260206004820152601d60248201527f457870697279206d75737420626520696e207468652066757475726521000000604482015290519081900360640190fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166350d25bcd6040518163ffffffff1660e01b815260040160206040518083038186803b15801561025957600080fd5b505afa15801561026d573d6000803e3d6000fd5b505050506040513d602081101561028357600080fd5b50519050600080806102958487610736565b9250925092506000808885106102e6576102b18385878c610823565b90925090506102df6402540be4006102d9670de0b6b3a76400006001607f1b86025b046108d5565b906109a3565b9650610335565b6102f283858b88610823565b90925090506103326402540be4006102d961031b670de0b6b3a76400006001607f1b86026102d3565b61032c600a6509184e72a000610a0c565b90610a6c565b96505b50505050505092915050565b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166350d25bcd6040518163ffffffff1660e01b815260040160206040518083038186803b15801561039c57600080fd5b505afa1580156103b0573d6000803e3d6000fd5b505050506040513d60208110156103c657600080fd5b5051919050565b7f000000000000000000000000000000000000000000000000000000000000000081565b7f000000000000000000000000000000000000000000000000000000000000000081565b600042821161046b576040805162461bcd60e51b815260206004820152601d60248201527f457870697279206d75737420626520696e207468652066757475726521000000604482015290519081900360640190fd5b600061047e620151806102d98542610a6c565b90506000808688106104c35761049683878a8a610823565b90925090506104bc6402540be4006102d9670de0b6b3a76400006001607f1b86026102d3565b93506104fb565b6104cf8387898b610823565b90925090506104f86402540be4006102d961031b670de0b6b3a76400006001607f1b86026102d3565b93505b505050949350505050565b600042831161055c576040805162461bcd60e51b815260206004820152601d60248201527f457870697279206d75737420626520696e207468652066757475726521000000604482015290519081900360640190fd5b60007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166350d25bcd6040518163ffffffff1660e01b815260040160206040518083038186803b1580156105b757600080fd5b505afa1580156105cb573d6000803e3d6000fd5b505050506040513d60208110156105e157600080fd5b50519050600080806105f38488610736565b9250925092506000806106088385878d610ac9565b9150915060006106668961063c577f000000000000000000000000000000000000000000000000000000000000000061065e565b7f00000000000000000000000000000000000000000000000000000000000000005b601290610a6c565b600a0a905088610688576106838361067e8984610a0c565b610b68565b61071b565b61071b8261067e837f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03166350d25bcd6040518163ffffffff1660e01b815260040160206040518083038186803b1580156106e957600080fd5b505afa1580156106fd573d6000803e3d6000fd5b505050506040513d602081101561071357600080fd5b505190610a0c565b97506107278882610a0c565b9b9a5050505050505050505050565b6000808061076f7f0000000000000000000000000000000000000000000000000000000000000000600a0a6102d9876305f5e100610a0c565b92506108076402540be4007f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031663950ed82c7f00000000000000000000000000000000000000000000000000000000000000006040518263ffffffff1660e01b815260040180826001600160a01b0316815260200191505060206040518083038186803b1580156106e957600080fd5b915061081a620151806102d98642610a6c565b90509250925092565b600080600280860a046ec097ce7bc90715b34b9f10000000008261016d670de0b6b3a764000084028390048a020490506000633b9aca0061087161016d670de0b6b3a76400008d0204610b90565b8a028161087a57fe5b0490506001607f1b61089a888a6001607f1b028161089457fe5b04610bc7565b670de0b6b3a764000002816108ab57fe5b04955080828701670de0b6b3a764000002816108c357fe5b049a908b039950975050505050505050565b6000806001607f1b6223549b8402046298968001905060006001607f1b84600286816108fd57fe5b04028161090657fe5b049050600061091482610c5b565b623cdfaf607f1b8161092257fe5b049050600083848586876578fcdaec22008161093a57fe5b05630115e6cf190162989680028161094e57fe5b0563010fd4fc0162989680028161096157fe5b0562366845190162989680028161097457fe5b056230bbd701830262989680028161098857fe5b059050851561099a57655af3107a4000035b95945050505050565b60008082116109f9576040805162461bcd60e51b815260206004820152601a60248201527f536166654d6174683a206469766973696f6e206279207a65726f000000000000604482015290519081900360640190fd5b818381610a0257fe5b0490505b92915050565b600082610a1b57506000610a06565b82820282848281610a2857fe5b0414610a655760405162461bcd60e51b81526004018080602001828103825260218152602001806112ed6021913960400191505060405180910390fd5b9392505050565b600082821115610ac3576040805162461bcd60e51b815260206004820152601e60248201527f536166654d6174683a207375627472616374696f6e206f766572666c6f770000604482015290519081900360640190fd5b50900390565b60008060008084861115610b1b57610ae388888888610fff565b915085610af9610af38488611073565b886110cd565b14610b1157610b0c8661032c8488611073565b610b14565b60005b9050610b5b565b610b2788888789610fff565b905084610b3d610b378389611073565b876110cd565b14610b5557610b508561032c8389611073565b610b58565b60005b91505b9097909650945050505050565b600081610b89610b8085670de0b6b3a76400006110e4565b60028504611147565b81610a0257fe5b80600260018201045b81811015610bc157809150600281828581610bb057fe5b040181610bb957fe5b049050610b99565b50919050565b600080600160801b8310610bf7576000610be66001607f1b8504611196565b60ff1693841c936001607f1b029150505b6001607f1b831115610c4557607f5b60ff811615610c43576001607f1b848002049350600160801b8410610c3a57600193841c9360ff6000198301161b91909101905b60001901610c06565b505b6402540be40064019d25ddbe8202049392505050565b6000670168244fdac780006001607f1b6f0fffffffffffffffffffffffffffffff84168080028290048082028390048083028490049485026710e1b3be415a00009092026705a0913f6b1e000091909102010192909181830204905080664807432bc1800002830192506001607f1b82820281610cd457fe5b04905080660c0135dca0400002830192506001607f1b82820281610cf457fe5b049050806601b707b1cdc00002830192506001607f1b82820281610d1457fe5b049050806536e0f639b80002830192506001607f1b82820281610d3357fe5b04905080650618fee9f80002830192506001607f1b82820281610d5257fe5b04905080649c197dcc0002830192506001607f1b82820281610d7057fe5b04905080640e30dce40002830192506001607f1b82820281610d8e57fe5b0490508064012ebd130002830192506001607f1b82820281610dac57fe5b049050806317499f0002830192506001607f1b82820281610dc957fe5b049050806301a9d48002830192506001607f1b82820281610de657fe5b04905080621c638002830192506001607f1b82820281610e0257fe5b049050806201c63802830192506001607f1b82820281610e1e57fe5b04905080611ab802830192506001607f1b82820281610e3957fe5b0490508061017c02830192506001607f1b82820281610e5457fe5b04905080601402830192506001607f1b82820281610e6e57fe5b6721c3677c82b400009190049384010482016001607f1b019290506001607c1b851615610ebf5770018ebef9eac820ae8682b9793ac6d1e7767001c3d6a24ed82218787d624d3e5eba95f984020492505b6001607d1b851615610ef5577001368b2fc6f9609fe7aceb46aa619baed470018ebef9eac820ae8682b9793ac6d1e77884020492505b6001607e1b851615610f2a576fbc5ab1b16779be3575bd8f0520a9f21f7001368b2fc6f9609fe7aceb46aa619baed584020492505b6001607f1b851615610f5e576f454aaa8efe072e7f6ddbab84b40a55c96fbc5ab1b16779be3575bd8f0520a9f21e84020492505b600160801b851615610f92576f0960aadc109e7a3bf4578099615711ea6f454aaa8efe072e7f6ddbab84b40a55c584020492505b600160811b851615610fc5576e2bf84208204f5977f9a8cf01fdce3d6f0960aadc109e7a3bf4578099615711d784020492505b600160821b851615610ff6576d03c6ab775dd0b95b4cbee7e65d116e2bf84208204f5977f9a8cf01fdc30784020492505b50909392505050565b600080600061101087878787610823565b915091506000611030670de0b6b3a7640000846001607f1b02816102d357fe5b9050600061104d670de0b6b3a76400006001607f1b8502056111f7565b9050655af3107a400086820204655af3107a400088840204039998505050505050505050565b600082820183811015610a65576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b6000818310156110dd5781610a65565b5090919050565b60008115806110ff575050808202828282816110fc57fe5b04145b610a06576040805162461bcd60e51b815260206004820152601460248201527364732d6d6174682d6d756c2d6f766572666c6f7760601b604482015290519081900360640190fd5b80820182811015610a06576040805162461bcd60e51b815260206004820152601460248201527364732d6d6174682d6164642d6f766572666c6f7760601b604482015290519081900360640190fd5b6000806101008310156111be575b60018311156111b957600192831c92016111a4565b610a06565b60805b60ff8116156111f057600160ff82161b84106111e55760ff81169390931c92908117905b60011c607f166111c1565b5092915050565b6000806001607f1b611208846112d6565b6223549b028161121457fe5b046298968001905060006001607f1b846002868161122e57fe5b05028161123757fe5b049050600061124582610c5b565b623cdfaf607f1b8161125357fe5b049050600083848586876578fcdaec22008161126b57fe5b05630115e6cf190162989680028161127f57fe5b0563010fd4fc0162989680028161129257fe5b056236684519016298968002816112a557fe5b056230bbd70183026298968002816112b957fe5b059050600086131561099a57655af3107a40000395945050505050565b60008082126112e55781610a06565b506000039056fe536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f77a26469706673582212201052d781aebd590db42ec7654dde6c0457ea505f1f32112ec61a598bfac2545b64736f6c63430007030033";
export const TestVolOracle_BYTECODE =
  "0x60c06040523480156200001157600080fd5b5060405162001c1538038062001c15833981810160405260208110156200003757600080fd5b50518063ffffffff81166200007e576040805162461bcd60e51b81526020600482015260086024820152670857dc195c9a5bd960c21b604482015290519081900360640190fd5b60e081901b6001600160e01b031916608052620000c7620000b66301e1338063ffffffff8416620000d3602090811b620008e517901c565b6200013c60201b6200094e1760201c565b60a052506200029c9050565b60008082116200012a576040805162461bcd60e51b815260206004820152601a60248201527f536166654d6174683a206469766973696f6e206279207a65726f000000000000604482015290519081900360640190fd5b8183816200013457fe5b049392505050565b6000816200014d5750600062000297565b50600181600160801b8110620001685760409190911b9060801c5b680100000000000000008110620001845760209190911b9060401c5b64010000000081106200019c5760109190911b9060201c5b620100008110620001b25760089190911b9060101c5b6101008110620001c75760049190911b9060081c5b60108110620001db5760029190911b9060041c5b60088110620001ec57600182901b91505b6001828481620001f857fe5b048301901c915060018284816200020b57fe5b048301901c915060018284816200021e57fe5b048301901c915060018284816200023157fe5b048301901c915060018284816200024457fe5b048301901c915060018284816200025757fe5b048301901c915060018284816200026a57fe5b048301901c915060008284816200027d57fe5b0490508083101562000290578262000292565b805b925050505b919050565b60805160e01c60a051611939620002dc60003980610620528061083752508061033f52806108c35280610aa05280610ad75280610b1a52506119396000f3fe608060405234801561001057600080fd5b506004361061009e5760003560e01c80639c1ed7d4116100665780639c1ed7d4146101ad578063b84e286e146101d3578063dabb54ec146101f9578063ebfe74a114610201578063ef78d4fd146102275761009e565b8063369e8c1d146100a35780634e869458146100cb578063641e65691461010357806391b7f5ed1461016a578063950ed82c14610187575b600080fd5b6100c9600480360360208110156100b957600080fd5b50356001600160a01b0316610248565b005b6100f1600480360360208110156100e157600080fd5b50356001600160a01b03166105a4565b60408051918252519081900360200190f35b6101296004803603602081101561011957600080fd5b50356001600160a01b03166105b6565b6040805161ffff909516855263ffffffff90931660208501526001600160601b03909116838301526001600160701b03166060830152519081900360800190f35b6100c96004803603602081101561018057600080fd5b50356105fc565b6100f16004803603602081101561019d57600080fd5b50356001600160a01b0316610601565b6100f1600480360360208110156101c357600080fd5b50356001600160a01b031661066d565b6100f1600480360360208110156101e957600080fd5b50356001600160a01b03166106a5565b6100f1610835565b6100c96004803603602081101561021757600080fd5b50356001600160a01b0316610859565b61022f6108c1565b6040805163ffffffff9092168252519081900360200190f35b600080610253610a94565b915091506107088163ffffffff16106102a6576040805162461bcd60e51b815260206004820152601060248201526f4e6f7420636f6d6d697420706861736560801b604482015290519081900360640190fd5b60006102b1846106a5565b6001600160a01b038516600090815260016020526040812054919250816102d95760006102e3565b6102e38383610b4a565b905060008082116102f557600061030d565b6402540be40061030483610b72565b8161030b57fe5b055b6001600160a01b03881660009081526020819052604090208054919250906107071963ffffffff6201000090920482167f000000000000000000000000000000000000000000000000000000000000000001909116014210156103a3576040805162461bcd60e51b815260206004820152600960248201526810dbdb5b5a5d1d195960ba1b604482015290519081900360640190fd5b8054600090819081906103dd9061ffff811690600160301b81046001600160601b031690600160901b90046001600160701b031688610b9e565b9194509250905061ffff8310610423576040805162461bcd60e51b815260206004808301919091526024820152631f2a989b60e11b604482015290519081900360640190fd5b6001600160601b038210610467576040805162461bcd60e51b815260206004808301919091526024820152631f2a9c9b60e11b604482015290519081900360640190fd5b6001600160701b0381106104aa576040805162461bcd60e51b81526020600482015260056024820152641f2a98989960d91b604482015290519081900360640190fd5b835463ffffffff8b1662010000810265ffffffff0000196001600160701b038516600160901b810271ffffffffffffffffffffffffffffffffffff6001600160601b038916600160301b810271ffffffffffffffffffffffff0000000000001961ffff8d1661ffff19909a168a1716179190911691909117929092169290921788556001600160a01b038f166000908152600160209081526040918290208e90558151958652850193909352838301526060830152608082018a90523360a0830152517f8825db851b7577f8609ff3326921d8f6bbc84af5470fc140b1d1ce7785e46af09181900360c00190a15050505050505050505050565b60016020526000908152604090205481565b60006020819052908152604090205461ffff81169062010000810463ffffffff1690600160301b81046001600160601b031690600160901b90046001600160701b031684565b600255565b6001600160a01b038116600090815260208190526040812054610665907f00000000000000000000000000000000000000000000000000000000000000009061065f9061ffff811690600160901b90046001600160701b0316610cc1565b90610cdc565b90505b919050565b6001600160a01b0381166000908152602081905260408120546106659061ffff811690600160901b90046001600160701b0316610cc1565b6000806000806106b485610d35565b92509250925060008590506000816001600160a01b0316630dfe16816040518163ffffffff1660e01b815260040160206040518083038186803b1580156106fa57600080fd5b505afa15801561070e573d6000803e3d6000fd5b505050506040513d602081101561072457600080fd5b50516040805163d21220a760e01b815290519192506000916001600160a01b0385169163d21220a7916004808301926020929190829003018186803b15801561076c57600080fd5b505afa158015610780573d6000803e3d6000fd5b505050506040513d602081101561079657600080fd5b5051905060006107a7878787610ee7565b90506000836001600160a01b031663313ce5676040518163ffffffff1660e01b815260040160206040518083038186803b1580156107e457600080fd5b505afa1580156107f8573d6000803e3d6000fd5b505050506040513d602081101561080e57600080fd5b505160ff169050600a81900a61082683828787610f3d565b9b9a5050505050505050505050565b7f000000000000000000000000000000000000000000000000000000000000000081565b600080610864610a94565b915091506107088163ffffffff16106108b7576040805162461bcd60e51b815260206004820152601060248201526f4e6f7420636f6d6d697420706861736560801b604482015290519081900360640190fd5b60006102b161102f565b7f000000000000000000000000000000000000000000000000000000000000000081565b600080821161093b576040805162461bcd60e51b815260206004820152601a60248201527f536166654d6174683a206469766973696f6e206279207a65726f000000000000604482015290519081900360640190fd5b81838161094457fe5b0490505b92915050565b60008161095d57506000610668565b50600181600160801b81106109775760409190911b9060801c5b600160401b811061098d5760209190911b9060401c5b64010000000081106109a45760109190911b9060201c5b6201000081106109b95760089190911b9060101c5b61010081106109cd5760049190911b9060081c5b601081106109e05760029190911b9060041c5b600881106109f057600182901b91505b60018284816109fb57fe5b048301901c91506001828481610a0d57fe5b048301901c91506001828481610a1f57fe5b048301901c91506001828481610a3157fe5b048301901c91506001828481610a4357fe5b048301901c91506001828481610a5557fe5b048301901c91506001828481610a6757fe5b048301901c91506000828481610a7957fe5b04905080831015610a8a5782610a8c565b805b949350505050565b600080428163ffffffff7f0000000000000000000000000000000000000000000000000000000000000000811690831681610acb57fe5b069050600263ffffffff7f0000000000000000000000000000000000000000000000000000000000000000160463ffffffff168163ffffffff161015610b18579081900392509050610b46565b7f00000000000000000000000000000000000000000000000000000000000000009182018190039350900390505b9091565b600081610b6b610b6285670de0b6b3a7640000611035565b60028504611098565b8161094457fe5b60006714057b7ef767814f670de0b6b3a7640000610b8f846110e7565b0281610b9757fe5b0592915050565b600080806001870181610bb186896111af565b90506000610bc9610bc28385611214565b8a906112cc565b90506000610bd788836111af565b90506000610bef610be88584611331565b8b906112cc565b905060008513610c31576040805162461bcd60e51b81526020600482015260086024820152670636f756e743c3d360c41b604482015290519081900360640190fd5b6000831215610c70576040805162461bcd60e51b815260206004820152600660248201526506d65616e3c360d41b604482015290519081900360640190fd5b6000811215610caf576040805162461bcd60e51b8152602060048083019190915260248201526306d323c360e41b604482015290519081900360640190fd5b939b919a509298509650505050505050565b6000610cd5610cd084846113da565b61094e565b9392505050565b600082610ceb57506000610948565b82820282848281610cf857fe5b0414610cd55760405162461bcd60e51b81526004018080602001828103825260218152602001806118986021913960400191505060405180910390fd5b600080600080849050600080826001600160a01b0316633850c7bd6040518163ffffffff1660e01b815260040160e06040518083038186803b158015610d7a57600080fd5b505afa158015610d8e573d6000803e3d6000fd5b505050506040513d60e0811015610da457600080fd5b50604080820151606090920151815163252c09d760e01b815261ffff841660048201529151929450925060009182916001600160a01b0387169163252c09d791602480820192608092909190829003018186803b158015610e0457600080fd5b505afa158015610e18573d6000803e3d6000fd5b505050506040513d6080811015610e2e57600080fd5b5080516020909101519092509050600061ffff80851690600187011681610e5157fe5b0661ffff169050600080876001600160a01b031663252c09d7846040518263ffffffff1660e01b81526004018082815260200191505060806040518083038186803b158015610e9f57600080fd5b505afa158015610eb3573d6000803e3d6000fd5b505050506040513d6080811015610ec957600080fd5b5080516020909101519d949c50909403995091975050505050505050565b60008383038163ffffffff8416600683900b81610f0057fe5b05905060008260060b128015610f2a57508363ffffffff168260060b81610f2357fe5b0760060b15155b15610f3457600019015b95945050505050565b600080610f49866113e5565b90506001600160801b036001600160a01b03821611610fb8576001600160a01b0380821680029084811690861610610f9857610f93600160c01b876001600160801b031683611717565b610fb0565b610fb081876001600160801b0316600160c01b611717565b925050611026565b6000610fd26001600160a01b03831680600160401b611717565b9050836001600160a01b0316856001600160a01b03161061100a57611005600160801b876001600160801b031683611717565b611022565b61102281876001600160801b0316600160801b611717565b9250505b50949350505050565b60025490565b60008115806110505750508082028282828161104d57fe5b04145b610948576040805162461bcd60e51b815260206004820152601460248201527364732d6d6174682d6d756c2d6f766572666c6f7760601b604482015290519081900360640190fd5b80820182811015610948576040805162461bcd60e51b815260206004820152601460248201527364732d6d6174682d6164642d6f766572666c6f7760601b604482015290519081900360640190fd5b60008082136110f557600080fd5b6000670de0b6b3a7640000831261110e57506001611128565b6000199050826ec097ce7bc90715b34b9f10000000000492505b600061113d670de0b6b3a764000085056117c6565b670de0b6b3a7640000808202945090915084821d9081141561116157505002610668565b6706f05b59d3b200005b60008113156111a657670de0b6b3a7640000828002059150671bc16d674ec80000821261119e579384019360019190911d905b60011d61116b565b50505002919050565b60008183038183128015906111c45750838113155b806111d957506000831280156111d957508381135b610cd55760405162461bcd60e51b81526004018080602001828103825260248152602001806118e06024913960400191505060405180910390fd5b600081611268576040805162461bcd60e51b815260206004820181905260248201527f5369676e6564536166654d6174683a206469766973696f6e206279207a65726f604482015290519081900360640190fd5b8160001914801561127c5750600160ff1b83145b156112b85760405162461bcd60e51b81526004018080602001828103825260218152602001806118776021913960400191505060405180910390fd5b60008284816112c357fe5b05949350505050565b60008282018183128015906112e15750838112155b806112f657506000831280156112f657508381125b610cd55760405162461bcd60e51b81526004018080602001828103825260218152602001806118566021913960400191505060405180910390fd5b60008261134057506000610948565b826000191480156113545750600160ff1b82145b156113905760405162461bcd60e51b81526004018080602001828103825260278152602001806118b96027913960400191505060405180910390fd5b8282028284828161139d57fe5b0514610cd55760405162461bcd60e51b81526004018080602001828103825260278152602001806118b96027913960400191505060405180910390fd5b600082828161094457fe5b60008060008360020b126113fc578260020b611404565b8260020b6000035b9050620d89e8811115611442576040805162461bcd60e51b81526020600482015260016024820152601560fa1b604482015290519081900360640190fd5b60006001821661145657600160801b611468565b6ffffcb933bd6fad37aa2d162d1a5940015b70ffffffffffffffffffffffffffffffffff169050600282161561149c576ffff97272373d413259a46990580e213a0260801c5b60048216156114bb576ffff2e50f5f656932ef12357cf3c7fdcc0260801c5b60088216156114da576fffe5caca7e10e4e61c3624eaa0941cd00260801c5b60108216156114f9576fffcb9843d60f6159c9db58835c9266440260801c5b6020821615611518576fff973b41fa98c081472e6896dfb254c00260801c5b6040821615611537576fff2ea16466c96a3843ec78b326b528610260801c5b6080821615611556576ffe5dee046a99a2a811c461f1969c30530260801c5b610100821615611576576ffcbe86c7900a88aedcffc83b479aa3a40260801c5b610200821615611596576ff987a7253ac413176f2b074cf7815e540260801c5b6104008216156115b6576ff3392b0822b70005940c7a398e4b70f30260801c5b6108008216156115d6576fe7159475a2c29b7443b29c7fa6e889d90260801c5b6110008216156115f6576fd097f3bdfd2022b8845ad8f792aa58250260801c5b612000821615611616576fa9f746462d870fdf8a65dc1f90e061e50260801c5b614000821615611636576f70d869a156d2a1b890bb3df62baf32f70260801c5b618000821615611656576f31be135f97d08fd981231505542fcfa60260801c5b62010000821615611677576f09aa508b5b7a84e1c677de54f3e99bc90260801c5b62020000821615611697576e5d6af8dedb81196699c329225ee6040260801c5b620400008216156116b6576d2216e584f5fa1ea926041bedfe980260801c5b620800008216156116d3576b048a170391f7dc42444e8fa20260801c5b60008460020b13156116ee5780600019816116ea57fe5b0490505b640100000000810615611702576001611705565b60005b60ff16602082901c0192505050919050565b600080806000198587098686029250828110908390030390508061174d576000841161174257600080fd5b508290049050610cd5565b80841161175957600080fd5b6000848688096000868103871696879004966002600389028118808a02820302808a02820302808a02820302808a02820302808a02820302808a02909103029181900381900460010186841190950394909402919094039290920491909117919091029150509392505050565b6000600160801b82106117db57608091821c91015b600160401b82106117ee57604091821c91015b640100000000821061180257602091821c91015b62010000821061181457601091821c91015b610100821061182557600891821c91015b6010821061183557600491821c91015b6004821061184557600291821c91015b600282106106685760010191905056fe5369676e6564536166654d6174683a206164646974696f6e206f766572666c6f775369676e6564536166654d6174683a206469766973696f6e206f766572666c6f77536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f775369676e6564536166654d6174683a206d756c7469706c69636174696f6e206f766572666c6f775369676e6564536166654d6174683a207375627472616374696f6e206f766572666c6f77a2646970667358221220282e80586d958ad5c30d0bd7cfaaf19f1f2c8a4cddf544689d670a47f3183fdd64736f6c63430007030033";
