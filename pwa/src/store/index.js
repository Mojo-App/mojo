import { ethers } from 'ethers';
import { defineStore } from 'pinia';
import { connect, resultsToObjects, SUPPORTED_CHAINS } from '@tableland/sdk';
import Storage from '../services/storage';
/* Import Smart Contract ABI */
import contractAbi from '../../../artifacts/contracts/MojoCore.sol/MojoCore.json';
/* Manually set our Contract Address */
const contractAddress = '0xa8533121Ae08dc3ec3fbfED9508abc0B35F32D6c';
/* Setup Offline Storage */
const db = new Storage('app');
db.read();
db.data ||= { version: '0.0.1', results: [], nftResults: [] };
/* LFG */
export const useStore = defineStore({
  id: 'store',
  state() {
    return {
      account: null,
      balance: null,
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
    addTracks(...tracks) {
      this.trackList.push(...tracks);
    },
    addNewArrivals(...tracks) {
      this.newArrivals.push(...tracks);
    },
    addTracks(...tracks) {
      this.trackList.push(...tracks);
    },
    addToCount(amount) {
      this.counter += amount;
    },
    // Mint NFT
    resetNftFiles() {
      this.filesNft = [];
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
    // IPFS Uploader
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
     * Set loader value in store
     */
    setLoader(value) {
      this.loading = value;
    },
    /**
     * Get User Metamask Account Balance
     */
    async getBalance() {
      this.setLoader(true);
      try {
        /*
         * First make sure we have access to window.ethereum
         */
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);
          const count = await contract.getBalance();
          const amount = ethers.utils.formatEther(count);
          /* Console log with some style */
          const stylesAmount = ['color: black', 'background: green'].join(';');
          console.log('%c💰 Get Balance Amount %s 💰', stylesAmount, amount);
          this.balance = amount;
          setLoader(false);
        }
      } catch (error) {
        this.setLoader(false);
        console.log('getBalance Error:', error);
      }
    },
    /**
     * Search Nfts on Tableland by Category ID or by Name
     * @param {String} cid
     * @param {String} name
     */
    async searchNfts(id, name) {
      console.log('Search by ID:', id);
      console.log('Search by Name:', name);

      this.setLoader(true);
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
          // const localTestnet = SUPPORTED_CHAINS.custom;
          const polygonTestnet = SUPPORTED_CHAINS['polygon-mumbai'];
          // Connect to the Tableland testnet (defaults to Goerli testnet)
          // @return {Connection} Interface to access the Tableland network and target chain
          // 0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68
          // Connect to the Tableland network
          const tableland = await connect({
            // network: polygonTestnet.network,
            chain: 'polygon-mumbai',
            chainId: 80001,
            contract: polygonTestnet.contract,
          })
            .then((connection) => {
              // Run a SQL select on our project table
              return connection.read('select * from mojo_80001_306');
              // return connection.read('select * from mojo_media_meta_80001_307');
            })
            .then((data) => {
              // Format and store our data in the points[] array
              // points = data.rows.map((d, id) => ({ x: d[2], y: d[3], id }));
              // return data.rows;
              console.log('data.rows', data.rows);
              this.trackList = [...data.rows];
            });
          console.log('tableland', tableland);

          // // Retrieve the SIWE token generated by the signer
          // // @return {Token} Signer's SIWE token string
          // const signersToken = await tableland.siwe();
          // console.log('signersToken', signersToken.token);

          // /* Tableland Signers Address */
          // const myAddress = await tableland.signer.getAddress();
          // console.log('myAddress', myAddress);

          // // Check if a user already has a table on Mumbai Testnet - chainId 80001
          // const mainHashRes = await tableland.hash(
          //   'CREATE TABLE mojo_80001 (id int, name text, description text, image text, external_url text, background_color text, attributes text, PRIMARY KEY (id));'
          // );
          // const appMainTableStructure = mainHashRes.structureHash;

          // // Check if a user already has a meta attributes table on Mumbai Testnet - chainId 80001
          // const metaAttrHashRes = await tableland.hash(
          //   'CREATE TABLE mojo_meta_attributes_80001 (id int, max_invocations int, royalty int, sales_total int, title text, category text, license text, website text, long_description text, preview_url text, audio_video_type text, audio_video_url text, resolution text, duration text, size text, created_at text, PRIMARY KEY (id));'
          // );
          // const appAttrTableStructure = metaAttrHashRes.structureHash;

          // // Returns an Object with the Tables the connected address owns
          // const tables = await tableland.list();
          // console.log('All Tableland Tables:', tables);

          // // Filters Tableland `tables` for matching `structure`s
          // const mainMatchingTables = Object.values(tables).filter(
          //   (table) => table.structure === appMainTableStructure
          // );
          // const attrMatchingTables = Object.values(tables).filter(
          //   (table) => table.structure === appAttrTableStructure
          // );

          // console.log('mainMatchingTables', mainMatchingTables);
          // console.log('attrMatchingTables', attrMatchingTables);

          // const results = await tableland.read(`SELECT * FROM ${tables[0]};`);
        }
      } catch (err) {
        console.error('Error loading Tracks:', err);
        return err;
      }
      this.setLoader(false);
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
      const response = await fetch('/tracks/new-arrivals.json');
      try {
        const result = await response.json();
        this.newArrivals = result;
      } catch (err) {
        this.newArrivals = [];
        console.error('Error loading new arrivals:', err);
        return err;
      }
      this.loading = false;
    },
  },
});
