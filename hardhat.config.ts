import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import {ALCHEMY_API_KEY, ROPSTEN_PRIVATE_KEY, ETHERSCAN_API_KEY} from "./secrets.js";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.1",
  networks: {
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${ROPSTEN_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};
