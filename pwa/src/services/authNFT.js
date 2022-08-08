import axios from "axios";
/* Get our Mojo Contract Address */
const mojoContractAddress = import.meta.env.VITE_MOJO_CORE_CONTRACT;
const etherScapAPI = import.meta.env.VITE_ETHERSCAN_API_KEY;

export default class authNFT {
  constructor() {
    this.endpoint = new URL("https://ipfs.infura.io:5001");
  }

  /**
   * @param {String} accountAddress
   * @param {String} tokenId
   * @returns {Promise<String|Error>}
   */
  async authAccountAddress(accountAddress = "", tokenIds = null) {
    // We need to specifically check for the OpenSea contract
    // this contract doesn't show up on etherscan
    // OpenSea used 1 contract for all NFTs minted on their site
    // so we need to do an extra check for a specific token id as well
    if (accountAddress === "0x495f947276749Ce646f68AC8c248420045cb7b5e" && tokenIds) {
      const response = await axios.get("https://api.opensea.io/api/v1/assets", {
        headers: {
          "X-API-KEY": "",
        },
        params: {
          owner: accountAddress,
          asset_contract_address: mojoContractAddress,
          token_ids: tokenIds,
        },
      });
      const data = response.data;
      console.log("Opensea Response Data: ", data);
      console.log("Opensea Response Status: ", response.status(200));
      return response.status(200).json({
        isAuthenticated: data.assets && data.assets.length > 0,
      });
    } else {
      const response = await axios.get("https://api.etherscan.io/api", {
        params: {
          module: "account",
          action: "tokenbalance",
          contractaddress: mojoContractAddress,
          address: accountAddress,
          tag: "latest",
          apikey: etherScapAPI,
        },
      });
      const data = response.data;
      console.log("Etherscan Response Data: ", data);
      console.log("Etherscan Response Status: ", response.status(200));
      return response.status(200).json({
        isAuthenticated: data.result > 0,
      });
    }
  }
}
