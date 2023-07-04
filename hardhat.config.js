require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks:{
    fuji: {
      url:process.env.INFURA_FUJI_ENDPOINT,
      accounts:[process.env.PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.FUJI_SCAN_API,
 }
};
