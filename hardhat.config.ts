import "@nomiclabs/hardhat-waffle";
import "hardhat-contract-sizer";
import "hardhat-log-remover";
import "solidity-coverage";

require("dotenv").config();

process.env.TEST_MNEMONIC =
  "test test test test test test test test test test test junk";

export default {
  accounts: {
    mnemonic: process.env.TEST_MNEMONIC,
  },
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        runs: 200,
        enabled: true,
      },
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: process.env.TEST_URI,
        gasLimit: 8e6,
        blockNumber: 12570201,
      },
    },
  },
  mocha: {
    timeout: 500000,
  },
};
