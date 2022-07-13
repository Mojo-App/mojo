require("@nomicfoundation/hardhat-toolbox");
require('@nomiclabs/hardhat-waffle');
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.12",
  defaultNetwork: 'alchemy',
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    hardhat: {
      blockGasLimit: 1350000000,
      gas: 1300000000,
    },
    // Alchemy cuurently using Polygon Mumbai Testnet
    alchemy: {
      url: process.env.ALCHEMY_API_URL,
      key: process.env.ALCHEMY_API_KEY,
      accounts: [process.env.PRIVATE_KEY],
      blockGasLimit: 1350000000,
      gas: 1300000000,
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "9Z9SFMXZ8M7VAZPSY13Q8GHRUKZSVBWYYD",
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 40000,
  },
};
