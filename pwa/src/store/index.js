import { ethers } from "ethers";
import { defineStore } from "pinia";
import { connect, resultsToObjects, SUPPORTED_CHAINS } from "@tableland/sdk";
import Storage from "../services/storage";
/* Import Smart Contract ABI */
import contractAbi from "../../../artifacts/contracts/MojoCore.sol/MojoCore.json";
/* Get our Mojo Contract Address */
const mojoContractAddress = import.meta.env.VITE_MOJO_CORE_CONTRACT;
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
      errorMessage: false,
      walletAddress: "",
      account: null,
      balance: null,
      tokens: [],
      trackList: [],
      newArrivals: [],
      counter: 0,
      filesNft: [],
      nftResults: db.data.nftResults,
      files: [],
      results: db.data.results,
      loading: false,
    };
  },
  getters: {
    getAccount(state) {
      return state.account;
    },
    getAccountBalance(state) {
      return state.balance;
    },
    getTokens(state) {
      return state.tokens;
    },
    getTrackList(state) {
      return state.trackList;
    },
    getNewArrivals(state) {
      return state.newArrivals;
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
    updateAccount(account) {
      this.account = account;
    },
    updateBalance(balance) {
      this.balance = balance;
    },
    addTokens(tokens) {
      this.tokens.push(...tokens);
    },
    resetTracks() {
      this.trackList = [];
    },
    addTracks(...tracks) {
      this.trackList.push(...tracks);
    },
    addNewArrivals(...tracks) {
      this.newArrivals.push(...tracks);
    },
    addToCount(amount) {
      this.counter += amount;
    },
    // Mint NFT
    resetNftFiles() {
      this.filesNft = [];
    },
    addNftFiles(files) {
      this.filesNft.push(...files);
    },
    addNftResults(files) {
      this.nftResults.push(...files);
      this.nftResults = this.nftResults.filter(function (cid) {
        return !!cid;
      });
      db.data.nftResults = [...this.nftResults];
      db.write();
    },
    // IPFS Uploader
    resetFiles() {
      this.files = [];
    },
    addFiles(files) {
      this.files.push(...files);
    },
    addResults(files) {
      this.results.push(...files);
      this.results = this.results.filter(function (cid) {
        return !!cid;
      });
      db.data.results = [...this.results];
      db.write();
    },
    /**
     * Set walletConnectionAttempted value in store
     */
    setWalletConnectionAttempted(value) {
      this.walletConnectionAttempted = value;
    },
    /**
     * Set isAuthenticated value in store
     */
    setIsAuthenticated(value) {
      this.isAuthenticated = value;
    },
    /**
     * Set errorMessage value in store
     */
    setErrorMessage(value) {
      this.errorMessage = value;
    },
    /**
     * Set loader value in store
     */
    setLoading(value) {
      this.loading = value;
    },
    /**
     * Get User 🦊 Metamask Account Balance
     */
    async getBalance() {
      this.setLoading(true);
      try {
        /*
         * First make sure we have access to window.ethereum
         */
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const contract = new ethers.Contract(mojoContractAddress, contractAbi.abi, signer);
          const count = await contract.getBalance();
          const amount = ethers.utils.formatEther(count);
          /* Console log with some style */
          const stylesAmount = ["color: black", "background: green"].join(";");
          console.log("%c💰 Get Balance Amount %s 💰", stylesAmount, amount);
          this.balance = amount;
          setLoading(false);
        }
      } catch (error) {
        this.setLoading(false);
        console.log("getBalance Error:", error);
      }
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
      longDescription,
      preview,
      audioVideoURL,
      animationURL,
      youtubeURL,
      resolution,
      duration
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
      console.log("longDescription :", longDescription);
      console.log("preview :", preview);
      console.log("audioVideoURL :", audioVideoURL);
      console.log("animationURL :", animationURL);
      console.log("youtubeURL :", youtubeURL);
      console.log("resolution :", resolution);
      console.log("duration :", duration);
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
          const attrMatchingTables = Object.values(tables).filter(
            (table) => table.structure === appAttrTableStructure
          );
          console.log("attrMatchingTables", attrMatchingTables);

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
     * Search Nfts on Tableland by Category ID or by Name
     * @param {String} cid
     * @param {String} name
     */
    async searchNfts(id, name) {
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
              const results = await connection.read(`SELECT * FROM mojo_80001_554`);
              const entries = resultsToObjects(results);
              return entries;
            })
            .then((data) => {
              // Format and store our data in the tracks[] array
              this.resetTracks();
              for (const { id, external_link } of data) {
                console.log(`${id}: ${external_link}`);
                this.addTracks({id, external_link});
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
     * Fetch New Arrivals
     * @param {String} cid
     * @param {String} link
     */
    async fetchNewArrivals() {
      this.loading = true;
      const response = await fetch("/tracks/new-arrivals.json");
      try {
        const result = await response.json();
        this.newArrivals = result;
      } catch (err) {
        this.newArrivals = [];
        console.error("Error loading new arrivals:", err);
        return err;
      }
      this.loading = false;
    },
  },
});
