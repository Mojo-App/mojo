import { defineStore } from 'pinia';
import Storage from '../services/storage';

const db = new Storage('app');

db.read();
db.data ||= { version: '0.0.1', results: [] };

export const useStore = defineStore({
  id: 'store',
  state() {
    return {
      counter: 0,
      user: {},
      playlists: [],
      playResults: db.data.playResults,
      files: [],
      results: db.data.results,
      newArrivals: [],
      fetching: false,
    };
  },
  getters: {
    getCount(state) {
      return state.counter;
    },
    user(state) {
      return state.user;
    },
    playlists(state) {
      return state.playlists;
    },
    results(state) {
      return state.newArrivals;
    },
    isFetching(state) {
      return state.fetching;
    },
  },
  actions: {
    updateUser(...user) {
      this.user = { ...user };
    },
    resetPlaylists() {
      this.playlists = [];
    },
    addPlaylists(...playlists) {
      this.playlists.push(...playlists);
    },
    addPlayResults(...playlists) {
      this.playResults.push(...playlists);
      this.playResults = this.playResults.filter(({ cid }) => !!cid);

      db.data.playResults = [...this.playResults];
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
      // BUG HERE
      this.results = this.results.filter(function (cid) {
        return !!cid;
      });
      console.log('this.results', this.results[0]);
      db.data.results = [...this.results[0]];

      console.log('db.data.results', db.data.results);
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
