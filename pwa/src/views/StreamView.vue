<template>
  <section id="content">
    <div class="main">
      <section id="stream">
        Account: {{ account }} <br />Tracks: {{ categoryTracks }}
        <div class="left">
          <h2>Find your groove</h2>
          <ul class="category-list">
            <li
              v-for="category of categories"
              :key="category"
              @click="selectCategory(category)"
              :class="categorySelectedId === category.id ? 'li-active' : ''"
            >
              <PlayButtonWhite
                v-if="categorySelectedId === category.id"
                class="category-list-play-button"
              />{{ category.label }}
            </li>
          </ul>
        </div>
        <div class="right">
          <div class="track-list">
            <TrackPlayer
              v-for="track in categoryTracks"
              :track="track"
              :key="track.id"
            ></TrackPlayer>
          </div>
        </div>
      </section>
    </div>
  </section>
</template>
<script setup>
import { ref, watch, onMounted } from 'vue';
import { Notyf } from 'notyf';
import { storeToRefs } from 'pinia';
/* Import our Pinia Store */
import { useStore } from '../store';
/* Components */
import PlayButtonWhite from '../components/icons/PlayButtonWhite.vue';
import TrackPlayer from '../components/TrackPlayer.vue';
// Create an instance of Notyf
var notyf = new Notyf({
  duration: 2000,
  position: {
    x: 'center',
    y: 'bottom',
  },
  types: [
    {
      type: 'loading',
      background: 'orange',
      duration: 0,
      dismissible: true,
      icon: {
        className: 'icon icon-loading',
        tagName: 'i',
      },
    },
  ],
});
// Init Store
const store = useStore();
// Store Values and Methods
const { account } = storeToRefs(store);
// Local Vars
const categorySelectedId = ref(1);
const categoryTracks = ref(null);
/**
 * Check if our Wallet is Connected to Metamask
 */
async function checkIfWalletIsConnected() {
  try {
    /*
     * First make sure we have access to window.ethereum
     */
    const { ethereum } = window;
    if (!ethereum) {
      notyf.error(`⛽ Please connect Metamask to continue!`);
      return;
    }
    /* Get our Current Account */
    const accounts = await ethereum.request({ method: 'eth_accounts' });
    /* Update our Current Account in the Store */
    if (accounts.length !== 0) store.updateAccount(accounts[0]);
  } catch (error) {
    console.log(error);
  }
}
/* Track Player */
const categories = ref([
  { id: 1, label: 'Fresh Jams' },
  { id: 2, label: 'Dance & Electronica' },
  { id: 3, label: 'Pop' },
  { id: 4, label: 'Jazz & Classical' },
  { id: 5, label: 'World & Ethnic' },
  { id: 6, label: 'Cinematic & Soundscapes' },
  { id: 7, label: 'More' },
]);
/* Select a new Category */
function selectCategory(category) {
  categorySelectedId.value = category.id;
  console.log('categorySelectedId:', categorySelectedId.value);
}
/* Fetch new NFT audio/media by Category or Name */
async function fetchData() {
  categoryTracks.value = await store.searchNfts(categorySelectedId.value);
  /* Console log with some style */
  const stylesTracks = ['color: black', 'background: yellow'].join(';');
  console.log('%c📻 NFT Audio/Media fetched : %s 📻', stylesTracks, categoryTracks.value);
}
/* Watch for Category Changes */
watch(categorySelectedId, fetchData);
fetchData();
onMounted(() => {
  checkIfWalletIsConnected();
});
</script>
<style lang="scss" scoped>
@import '../assets/styles/variables.scss';
@import '../assets/styles/mixins.scss';

section#content {
  position: relative;
  height: 100%;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#stream {
      height: 100%;
      color: #212121;
      background: #1c8bfe;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 0;
      overflow: hidden;

      @include breakpoint($medium) {
        padding: 0;
        flex-direction: row;
        align-content: center;
        align-items: flex-start;
        justify-content: center;
      }

      .left {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        padding: 50px 20px 60px 60px;

        @include breakpoint($medium) {
          width: 29%;
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 60px 20px 0;

        .track-list {
          width: 100%;
          max-width: 960px;
          display: inline-block;
          margin: 0 auto;
        }
      }

      h2 {
        font-size: 2.45rem;
        margin: 0;
      }

      a {
        color: #1a1a1a;
        font-weight: bold;
        border-bottom: 1px solid var(--contrast-color);
        text-decoration: none;

        &.author {
          padding: 6px 12px;
          border-radius: 8px;
          background-color: var(--gradient-100);
          color: var(--icon-color);
          font-size: 0.85rem;

          border-bottom: none;
        }
      }

      p {
        line-height: 1.7;
        margin-bottom: 20px;
      }

      ul.category-list {
        list-style-type: none;
        list-style-position: outside;
        margin-block-start: 1em;
        margin-block-end: 1em;
        margin-inline-start: 0px;
        margin-inline-end: 0px;
        padding-inline-start: 0;
        border-top: 1px solid #1a1a1a;

        li {
          font-size: 22px;
          font-weight: 700;
          line-height: 1.75rem;
          padding-top: 0.75rem;
          padding-bottom: 0.75rem;
          padding-left: 1rem;
          padding-right: 1rem;
          border-bottom: 1px solid #1a1a1a;

          &:hover {
            color: #fff;
            cursor: pointer;
          }

          &:active {
            color: #fff;
            font-weight: 600;
          }
        }
      }

      .li-active {
        color: #fff;
        font-weight: 600;
      }

      .category-list-play-button {
        margin: 0 5px 0 -15px;
      }
    }
  }
}

body.dark-theme {
  section#content .main section#stream .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .stream {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
