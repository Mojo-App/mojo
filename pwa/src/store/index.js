import { ethers } from "ethers";
import { defineStore } from "pinia";

/* Import Tableland sdk */
import { connect, resultsToObjects, SUPPORTED_CHAINS } from "@tableland/sdk";

/* Import services and helpers */
import Storage from "../services/storage";
import nftPort from "../services/nftPort.js";

/* Import Smart Contract ABI and Mojo Contract Address */
// import contractAbi from "../../../artifacts/contracts/mojo_ERC721.sol/MOJO.json";
// const mojoContractAddress = "0x13B9DF4c7C97563fAD045251FCA95a9E61c9Dc85";

/* Setup Offline Storage */
const db = new Storage("app");
db.read();
db.data ||= { version: "0.0.1", results: [], nftResults: [] };

/* LFG */
export const useStore = defineStore({
  id: "store",
  state() {
    return {
      walletConnectionAttempted: false,
      isAuthenticated: false,
      isRigHolder: false,
      errorMessage: false,
      walletAddress: "",
      errorCode: null,
      errorStatus: null,
      errorMessage: "",
      loading: false,
      minting: false,
      bridging: false,
      fileLoading: false,
      account: null,
      balance: null,
      searchChainId: "all",
      searchContract: "",
      searchName: "",
      searchImage: "",
      searchResults: [],
      ethereumTokens: [],
      polygonTokens: [],
      optimismTokens: [],
      arbitrumTokens: [],
      avalancheTokens: [],
      homeTokens: [],
      trendingTokens: [],
      topTokens: [],
      latestTokens: [],
      mojoMCNFTTokens: [],
      trackList: [],
      musicCategories: [],
      counter: 0,
      filesNft: [],
      nftResults: db.data.nftResults,
      files: [],
      results: db.data.results,
      loading: false,
    };
  },
  getters: {
    isErrorCode(state) {
      return state.errorCode;
    },
    isErrorCode(state) {
      return state.errorCode;
    },
    isErrorStatus(state) {
      return state.errorStatus;
    },
    isErrorMessage(state) {
      return state.errorMessage;
    },
    isLoading(state) {
      return state.loading;
    },
    isMinting(state) {
      return state.minting;
    },
    isBridging(state) {
      return state.bridging;
    },
    isFileLoading(state) {
      return state.fileLoading;
    },
    getWalletConnectionAttempted(state) {
      return state.walletConnectionAttempted;
    },
    getIsAuthenticated(state) {
      return state.isAuthenticated;
    },
    getIsRigHolder(value) {
      return state.isRigHolder;
    },
    getAccount(state) {
      return state.account;
    },
    getBalance(state) {
      return state.balance;
    },
    getSearchChainId(state) {
      return state.searchChainId;
    },
    getSearchContract(state) {
      return state.searchContract;
    },
    getSearchName(state) {
      return state.searchName;
    },
    getSearchImage(state) {
      return state.searchImage;
    },
    getSearchResults(state) {
      return state.searchResults;
    },
    getEthereumTokens(state) {
      return state.ethereumTokens;
    },
    getPolygonTokens(state) {
      return state.polygonTokens;
    },
    getOptimismTokens(state) {
      return state.optimismTokens;
    },
    getArbitrumTokens(state) {
      return state.arbitrumTokens;
    },
    getAvalancheTokens(state) {
      return state.avalancheTokens;
    },
    getHomeTokens(state) {
      return state.homeTokens;
    },
    getTrendingTokens(state) {
      return state.trendingTokens;
    },
    getTopTokens(state) {
      return state.topTokens;
    },
    getLatestTokens(state) {
      return state.latestTokens;
    },
    getMojoMCNFTTokens(state) {
      return state.mojoMCNFTTokens;
    },
    getTrackList(state) {
      return state.trackList;
    },
    getMusicCategories(state) {
      return state.musicCategories;
    },
    getCount(state) {
      return state.counter;
    },
    getNftResults(state) {
      return state.nftResults;
    },
    getResults(state) {
      return state.results;
    },
    isLoading(state) {
      return state.loading;
    },
  },
  actions: {
    setWalletConnectionAttempted(value) {
      this.walletConnectionAttempted = value;
    },
    setIsAuthenticated(value) {
      this.isAuthenticated = value;
    },
    setIsRigHolder(value) {
      this.isRigHolder = value;
    },
    setErrorCode(value) {
      this.errorCode = value;
    },
    setErrorStatus(value) {
      this.errorStatus = value;
    },
    setErrorMessage(value) {
      this.errorMessage = value;
    },
    setLoading(value) {
      this.loading = value;
    },
    setMinting(value) {
      this.minting = value;
    },
    setBridging(value) {
      this.bridging = value;
    },
    setFileLoading(value) {
      this.fileLoading = value;
    },
    updateAccount(account) {
      this.account = account;
    },
    updateBalance(balance) {
      this.balance = balance;
    },
    updateSearchChainId(searchChainId) {
      this.searchChainId = searchChainId;
    },
    updateSearchContract(searchContract) {
      this.searchContract = searchContract;
    },
    updateSearchName(searchName) {
      this.searchName = searchName;
    },
    updateSearchImage(searchImage) {
      this.searchImage = searchImage;
    },
    addSearchResults(...tokens) {
      this.searchResults.push(...tokens);
    },
    clearSearchResults() {
      this.searchChainId = "all";
      this.searchContract = "";
      this.searchName = "";
      this.searchImage = "";
      this.searchResults = [];
    },
    addEthereumTokens(...tokens) {
      this.ethereumTokens.push(...tokens);
    },
    addPolygonTokens(...tokens) {
      this.polygonTokens.push(...tokens);
    },
    addOptimismTokens(...tokens) {
      this.optimismTokens.push(...tokens);
    },
    addArbitrumTokens(...tokens) {
      this.arbitrumTokens.push(...tokens);
    },
    addAvalancheTokens(...tokens) {
      this.avalancheTokens.push(...tokens);
    },
    addHomeTokens(...tokens) {
      this.homeTokens.push(...tokens);
    },
    addTrendingTokens(...tokens) {
      this.trendingTokens.push(...tokens);
    },
    addTopTokens(...tokens) {
      this.topTokens.push(...tokens);
    },
    addLatestTokens(...tokens) {
      this.latestTokens.push(...tokens);
    },
    addMojoMCNFTTokens(...tokens) {
      this.mojoMCNFTTokens.push(...tokens);
    },
    resetTracks() {
      this.trackList = [];
    },
    addTracks(...tracks) {
      this.trackList.push(...tracks);
    },
    addMusicCategories(...tracks) {
      this.musicCategories.push(...tracks);
    },
    addToCount(amount) {
      this.counter += amount;
    },
    addNftFiles(...files) {
      this.filesNft.push(...files);
    },
    addNftResults(...files) {
      this.nftResults.push(...files);
      this.nftResults = this.nftResults.filter(function (cid) {
        return !!cid;
      });
      db.data.nftResults = [...this.nftResults];
      db.write();
    },
    resetNftFiles() {
      this.nftResults = [];
      db.data.nftResults = [];
      db.write();
    },
    /* IPFS Uploader */
    resetFiles() {
      this.files = [];
    },
    addFiles(...files) {
      this.files.push(...files);
    },
    addResults(...files) {
      this.results.push(...files);
      this.results = this.results.filter(function (cid) {
        return !!cid;
      });
      db.data.results = [...this.results];
      db.write();
    },
    /**
     * Update Shorten Link for File
     * @param {String} cid
     * @param {String} link
     */
    updateShortenLink(cid, link) {
      this.results = this.results.map((result) => {
        if (result.cid === cid) {
          return { ...result, shorten: link };
        }
        return result;
      });
      db.data.results = [...this.results];
      db.write();
    },

    /**
     * Get User 🦊 Metamask Account Balance
     */
    // async loadBalance() {
    //   this.setLoading(true);
    //   try {
    //     /*
    //      * First make sure we have access to window.ethereum
    //      */
    //     const { ethereum } = window;
    //     if (ethereum) {
    //       const provider = new ethers.providers.Web3Provider(ethereum);
    //       const signer = provider.getSigner();
    //       const contract = new ethers.Contract(mojoContractAddress, contractAbi.abi, signer);
    //       const count = await contract.getBalance();
    //       const amount = ethers.utils.formatEther(count);
    //       /* Console log with some style */
    //       const stylesAmount = ["color: black", "background: green"].join(";");
    //       console.log("%c💰 Get Balance Amount %s 💰", stylesAmount, amount);
    //       this.balance = amount;
    //       setLoading(false);
    //     }
    //   } catch (error) {
    //     this.setLoading(false);
    //     console.log("Load Balance Error:", error);
    //   }
    // },

    /**
     * Creates a Music Category entry in Tableland,
     */
    async getCategories() {
      // Connect to the Tableland testnet (defaults to Polygon Mumbai testnet chain)
      // @return {Connection} Interface to access the Tableland network and, optionally, a target `chain`
      const tableland = await connect({ network: "testnet", chain: "polygon-mumbai" });

      // Run a SQL SELECT query
      // @return {ReadQueryResult} Tableland gateway response with row & column values
      const { rows } = await tableland.read(
        `SELECT id, position, value, label FROM Mojo_Music_80001_3473;`
      );

      // console.log("columns", columns);
      // [ { name: 'name' }, { name: 'id' } ]
      // console.log("rows", rows);
      // [ [ 'Bobby Tables', 0 ], [ 'Molly Tables', 1 ] ]

      /* Loop through our Music Categories from Tableland */
      let i = 0;
      for (i in rows) {
        let id = rows[i][0];
        let position = rows[i][1];
        let value = rows[i][2];
        let label = rows[i][3];
        this.musicCategories.push({ id: id, position: position, value: value, label: label });
        i++;
      }
    },


     /**
     * Search Nfts on Tableland by Category Value or by Name
     * @param {String} cid
     * @param {String} name
     */
      async searchMojoNfts(id, name) {
        console.log("Search by ID:", id);
        console.log("Search by Name:", name);

        this.setLoading(true);
        // Run a SQL SELECT query
        try {
          /*
           * First make sure we have access to window.ethereum
           */
          const { ethereum } = window;
          if (ethereum) {
            const provider = new ethers.providers.Web3Provider(ethereum);
            const signer = provider.getSigner();

            // ... access chain config information for localhost or Polygon Mumbai
            // Connect to the Tableland testnet (defaults to Goerli testnet)
            // @return {Connection} Interface to access the Tableland network and target chain
            // tableland chains
            // {
            //   "ethereum-goerli": {
            //     "name": "goerli",
            //     "phrase": "Ethereum Goerli",
            //     "chainId": 5,
            //     "contract": "0xDA8EA22d092307874f30A1F277D1388dca0BA97a",
            //     "host": "https://testnet.tableland.network"
            //   },
            //   "optimism-kovan": {
            //     "name": "optimism-kovan",
            //     "phrase": "Optimism Kovan",
            //     "chainId": 69,
            //     "contract": "0xf2C9Fc73884A9c6e6Db58778176Ab67989139D06",
            //     "host": "https://testnet.tableland.network"
            //   },
            //   "polygon-mumbai": {
            //     "name": "maticmum",
            //     "phrase": "Polygon Testnet",
            //     "chainId": 80001,
            //     "contract": "0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68",
            //     "host": "https://testnet.tableland.network"
            //   },
            //   "local-tableland": {
            //     "name": "localhost",
            //     "phrase": "Local Tableland",
            //     "chainId": 31337,
            //     "contract": "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
            //     "host": "http://localhost:8080"
            //   }
            // }
            // const localTestnet = SUPPORTED_CHAINS.custom;

            const polygonTestnet = SUPPORTED_CHAINS["polygon-mumbai"];
            // Connect to the Tableland network
            const tableland = await connect({
              name: polygonTestnet.name,
              phrase: polygonTestnet.phrase,
              chainId: polygonTestnet.chainId,
              contract: polygonTestnet.contract,
              host: polygonTestnet.host,
            })
              .then(async (connection) => {
                // Run a SQL select on our Mojo table
                // const results = await connection.read(`SELECT * FROM mojo_80001_554`);
                const results = await connection.read(`SELECT * FROM mojo_80001_1199`);
                const entries = resultsToObjects(results);
                return entries;
              })
              .then((data) => {
                // Format and store our data in the tracks[] array
                this.resetTracks();
                for (const { id, external_link } of data) {
                  console.log(`${id}: ${external_link}`);
                  this.addTracks({ id, external_link });
                }
              });
          }
        } catch (err) {
          console.error("Error loading Tracks:", err);
          return err;
        }
        this.setLoading(false);
      },





    /**
     * Creates a row entry for new NFT in Tableland,
     * @dev Checks if table exists first, otherwise performs the CREATE TABLE
     */
    async createRow(
      tokenId,
      cid,
      name,
      description,
      externalUrl,
      imageUrl,
      size,
      createdAt,
      audioVideoType,
      maxInvocations,
      royaltyPercentage,
      price,
      title,
      category,
      license,
      website,
      preview,
      audioVideoURL,
      animationURL,
      youtubeURL,
      backgroundColor,
      resolution,
    ) {
      console.log("tokenId :", tokenId);
      console.log("cid :", cid);
      console.log("name :", name);
      console.log("description :", description);
      console.log("externalUrl :", externalUrl);
      console.log("imageUrl :", imageUrl);
      console.log("size :", size);
      console.log("createdAt :", createdAt);
      console.log("audioVideoType :", audioVideoType);
      console.log("maxInvocations :", maxInvocations);
      console.log("royaltyPercentage :", royaltyPercentage);
      console.log("price :", price);
      console.log("title :", title);
      console.log("category :", category);
      console.log("license :", license);
      console.log("website :", website);
      console.log("preview :", preview);
      console.log("audioVideoURL :", audioVideoURL);
      console.log("animationURL :", animationURL);
      console.log("youtubeURL :", youtubeURL);
      console.log("backgroundColor :", backgroundColor);
      console.log("resolution :", resolution);
      this.setLoading(true);
      // Run a SQL SELECT query
      try {
        /*
         * First make sure we have access to window.ethereum
         */
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const polygonTestnet = SUPPORTED_CHAINS["polygon-mumbai"];

          // Connect to the Tableland network on Polygon
          const tableland = await connect({
            name: polygonTestnet.name,
            phrase: polygonTestnet.phrase,
            chainId: polygonTestnet.chainId,
            contract: polygonTestnet.contract,
            host: polygonTestnet.host,
          });

          // Retrieve the SIWE token generated by the signer
          // @return {Token} Signer's SIWE token string
          // const signersToken = await tableland.siwe();
          // console.log("signersToken", signersToken.token);

          /* Tableland Signers Address */
          // const myAddress = await tableland.signer.getAddress();
          // console.log("myAddress", myAddress);

          // Check if we can load our main table to UPDATE our aid and gid
          const metaAttrHashRes = await tableland.hash(
            "CREATE TABLE mojo_80001 (id int, external_link text);"
          );
          const appAttrTableStructure = metaAttrHashRes.structureHash;
          // Returns an Object with the Tables the connected address owns
          const tables = await tableland.list();
          console.log("All Tableland Tables:", tables);

          /* Test if we find our Main Mojo NFT table created by our MojoCore smart contract */
          // const attrMatchingTables = Object.values(tables).filter(
          //   (table) => table.structure === appAttrTableStructure
          // );
          // console.log("attrMatchingTables", attrMatchingTables);

          /* Create a new table for our NFT metadata */

          /* Update aid Attributes ID in our metadata attributes table */

          // const results = await tableland.read(`SELECT * FROM ${tables[0]};`);
        }
      } catch (err) {
        console.error("Error loading Tracks:", err);
        return err;
      }
      this.setLoading(false);
    },



    /**
     * NFT PORT API - Search NFTs by Name and filter by Contract Address
     * @param {String} contract Results will only include NFTs from this contract address.
     * @param {String} text Required Search query
     * @param {String} chain Allowed values: polygon / ethereum / all
     * @param {String} sort_order Allowed values: desc / asc
     * @param {String} order_by Allowed values: relevance / mint_date
     * @param {Integer} page_size Required Search query
     * @param {Integer} page_number Required Search query
     */
    async searchNFTs(contract, text, chain, sort_order, order_by, page_size, page_number) {
      /* NFT Port API Search */
      const nftPortApi = new nftPort();
      const results = await nftPortApi.nftSearch(
        text,
        contract,
        chain,
        sort_order,
        order_by,
        page_size,
        page_number
      );
      return results;
    },

    /**
     * NFT PORT API - Search NFTs by Image URL and filter by Contract Address
     * @param {String} contract Results will only include NFTs from this contract address.
     * @param {String} imageUrl URL that points to the image that returns a Content-Length and Content-Type header or contains the file extension. Supports .JPG, .JPEG, .PNG, .WebP, .PPM, .BMP, .PGM, .TIF, .TIFF file formats.
     * @param {Integer} page_size Required Search query
     * @param {Integer} page_number Required Search query
     * @param {Number} threshold Threshold for classifying an NFT as a counterfeit. >= 0.1 <= 1 Default: 0.9
     */
    async searchNFTImage(contract, imageUrl, page_size, page_number, threshold) {
      /* NFT Port API Search */
      const nftPortApi = new nftPort();
      const results = await nftPortApi.nftSearchImage(
        imageUrl,
        contract,
        page_size,
        page_number,
        threshold
      );
      return results;
    },

    /**
     * NFT PORT API - Search NFTs by Token Id and filter by Contract Address
     * @param {String} contract Results will only include NFTs from this contract address.
     * @param {String} contractFilter NFTs from this contract address will be filtered out. Useful for examples where the whole NFT collection is visually very similar e.g. CryptoPunks.
     * @param {String} text
     * @param {String} tokenId A unique uint256 ID inside the contract. The contract address and token ID pair is a globally unique and fully-qualified identifier for a specific NFT on chain.
     * @param {String} chain Blockchain where the NFT has been minted. Allowed values: polygon / ethereum / all
     * @param {Integer} page_size Required Search query
     * @param {Integer} page_number Required Search query
     * @param {Number} threshold Threshold for classifying an NFT as a counterfeit. >= 0.1 <= 1 Default: 0.9
     */
    async searchNFTTokenId(
      contract,
      contractFilter,
      tokenId,
      text,
      chain,
      page_size,
      page_number,
      threshold
    ) {
      /* NFT Port API Search */
      const nftPortApi = new nftPort();
      const results = await nftPortApi.nftSearchTokenId(
        contract,
        contractFilter,
        tokenId,
        text,
        chain,
        page_size,
        page_number,
        threshold
      );
      return results;
    },

    /**
     * NFT PORT API - Fetch NFTs by Contract Address
     * @param {String} contract Results will only include NFTs from this contract address.
     * @param {String} chain Allowed values: polygon / ethereum / rinkeby
     * @param {String} include Include optional data in the response. default Allowed values: default / metadata / all
     * @param {Bool} refresh_metadata Queues and refreshes all the NFTs metadata inside the contract (i.e. all tokens)
     * if they have changed since the updated_date. Useful for example, when NFT collections are revealed.
     * @param {Integer} page_size Required Search query
     * @param {Integer} page_number Required Search query
     * @returns {Promise<String|Error>}
     */
    async contractNftSearch(contract, chain, include, refresh_metadata, page_size, page_number) {
      /* NFT Port API Search */
      const nftPortApi = new nftPort();
      const results = await nftPortApi.contractNftSearch(
        contract,
        chain,
        include,
        refresh_metadata,
        page_size,
        page_number
      );
      return results;
    },

    /**
     * NFT PORT API - Fetch NFTs by Account Address
     * @param {String} account Results will only include NFTs from this account address.
     * @param {String} contract Filter by and return NFTs only from the given contract address.
     * @param {String} chain Allowed values: polygon / ethereum / rinkeby
     * @param {String} include Include optional data in the response. default is the default response and metadata includes NFT metadata, like in Retrieve NFT details, and contract_information includes information of the NFT’s contract.
     * Allowed values: default / metadata / contract_information  Default: default
     * @param {String} exclude Exclude data from the response. erc721 excludes ERC721 tokens and erc1155 excludes ERC1155 tokens. Allowed values: erc721 / erc1155
     * @param {Integer} page_size Required Search query
     */
    async accountNftSearch(account, contract, chain, include, exclude, page_size) {
      /* NFT Port API Search */
      const nftPortApi = new nftPort();
      const results = await nftPortApi.accountNftSearch(
        account,
        contract,
        chain,
        include,
        exclude,
        page_size
      );
      return results;
    },

    /**
     * NFT PORT API - Fetch NFT Details by Contract and Token Id
     * @param {String} contract Results will only include NFTs from this contract address.
     * @param {String} token_id Results will only include NFTs from this contract address.
     * @param {String} chain Allowed values: polygon / ethereum / rinkeby
     * @param {Bool} refresh_metadata Queues and refreshes all the NFTs metadata inside the contract (i.e. all tokens)
     */
    async detailsNftSearch(contract, token_id, chain, refresh_metadata) {
      /* NFT Port API Search */
      const nftPortApi = new nftPort();
      const results = await nftPortApi.detailsNftSearch(
        contract,
        token_id,
        chain,
        refresh_metadata
      );
      return results;
    },
  },
});
