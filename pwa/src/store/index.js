import { defineStore } from 'pinia';
import Storage from '../services/storage';

const db = new Storage('app');

db.read();
db.data ||= { version: '0.0.1', results: [], nftResults: [] };

export const useStore = defineStore({
  id: 'store',
  state() {
    return {
      account: null,
      filesNft: [],
      nftResults: db.data.nftResults,
      files: [],
      results: db.data.results,
      newArrivals: [],
      counter: 0,
      fetching: false,
    };
  },
  getters: {
    getAccount(state) {
      return state.account;
    },
    getNftResults(state) {
      return state.nftResults;
    },
    getResults(state) {
      return state.results;
    },
    getNewArrivals(state) {
      return state.newArrivals;
    },
    getCount(state) {
      return state.counter;
    },
    isFetching(state) {
      return state.fetching;
    },
  },
  actions: {
    updateAccount(account) {
      this.account = account;
    },
    resetNftFiles() {
      this.filesNft = [];
    },
    addNftFiles(...files) {
      this.filesNft.push(...files);
    },
    addNftResults(...files) {
      this.nftResults.push(...files);
      this.results = this.nftResults.filter(function (cid) {
        return !!cid;
      });

      console.log("this.results[0]", this.results[0]);

      db.data.nftResults = [...this.results[0]];
      console.log('db.data.nftResults', db.data.nftResults);
      db.write();
    },
    resetFiles() {
      this.files = [];
    },
    addFiles(...files) {
      this.files.push(...files);
    },
    addResults(...files) {
      this.results.push(...files);
      console.log('this.results', this.results);
      this.results = this.results.filter(function (cid) {
        return !!cid;
      });
      db.data.results = [...this.results[0]];
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
     * Fetch New Arrivals
     * @param {String} cid
     * @param {String} link
     */
    async fetchNewArrivals() {
      this.fetching = true;
      const response = await fetch('/tracks/new-arrivals.json');
      try {
        const result = await response.json();
        this.newArrivals = result;
      } catch (err) {
        this.newArrivals = [];
        console.error('Error loading new arrivals:', err);
        return err;
      }
      this.fetching = false;
    },
  },
});
