<template>
  <section id="stream-content">
    <div class="main">
      <section id="stream">
        <div class="left">
          <h2>Find your groove</h2>
          <ul class="category-list">
            <li
              v-for="category of musicCategories"
              :key="category.id"
              @click="selectCategory(category)"
              :class="categorySelected === category.value ? 'li-active' : ''"
            >
              <PlayButtonWhite
                v-if="categorySelected === category.value"
                class="category-list-play-button"
              />{{ category.label }}
            </li>
          </ul>
        </div>
        <div class="right">
          <div class="track-list">
            <TrackPlayer v-for="track in trackList" :track="track" :key="track.id"></TrackPlayer>
          </div>
          <div v-if="trackList.length === 0">
            <div class="dj-graphic">
              <img src="../assets/images/DJ.png" alt="DJ Saved my Life" />
            </div>
            <h2>Please be patient while we spin another mix...</h2>
          </div>
        </div>
      </section>
    </div>
  </section>
</template>
<script setup>
import { ref, watch, onMounted } from "vue";
import { Notyf } from "notyf";
import { storeToRefs } from "pinia";
/* Import our Pinia Store */
import { useStore } from "../store";
/* Components */
import PlayButtonWhite from "../components/icons/PlayButtonWhite.vue";
import TrackPlayer from "../components/TrackPlayer.vue";
/* Create an instance of Notyf with settings */
var notyf = new Notyf({
  duration: 5000,
  position: {
    x: "center",
    y: "bottom",
  },
  types: [
    {
      type: "loading",
      background: "orange",
      duration: 15000,
      dismissible: true,
      icon: {
        className: "icon icon-loading",
        tagName: "i",
      },
    },
    {
      type: "success",
      background: "green",
      duration: 20000,
      dismissible: true,
      icon: {
        className: "icon icon-success",
        tagName: "i",
      },
    },
    {
      type: "error",
      background: "indianred",
      duration: 10000,
      dismissible: true,
      icon: {
        className: "icon icon-error",
        tagName: "i",
      },
    },
  ],
});
/* Init Store */
const store = useStore();
const { musicCategories, trackList } = storeToRefs(store);
/* Local variables */
const categorySelected = ref("fresh-jams");

/**
 * Check if our Wallet is Connected to 🦊 Metamask
 */
async function checkIfWalletIsConnected() {
  try {
    /*
     * First make sure we have access to window.ethereum
     */
    const { ethereum } = window;
    if (!ethereum) {
      notyf.error(`Please connect 🦊 Metamask to continue!`);
      return;
    }
    /* Get our Current Account */
    const accounts = await ethereum.request({ method: "eth_accounts" });
    /* Update our Current Account in the Store */
    if (accounts.length !== 0) store.updateAccount(accounts[0]);
  } catch (error) {
    console.log(error);
  }
}

/* Track Player */
// const categories = ref([
//   { id: 1, value: "fresh-jams", label: "Fresh Jams" },
//   { id: 2, value: "", label: "Dance & Electronica" },
//   { id: 3, value: "", label: "Pop" },
//   { id: 4, value: "", label: "Jazz & Classical" },
//   { id: 5, value: "", label: "World & Ethnic" },
//   { id: 6, value: "", label: "Cinematic & Soundscapes" },
//   { id: 7, value: "", label: "More" },
// ]);

/* Select a new Category */
function selectCategory(category) {
  categorySelected.value = category.value;
  console.log("Music Category Selected:", categorySelected.value);
}

/**
 * Fetch NFT Audio/Media category data from Tableland
 */
async function fetchMusicCategories() {
  try {
    await store.getCategories();
  } catch (error) {
    console.log(error);
  }
}

/* Fetch new NFT audio/media by Category or Name */
async function fetchData() {
  console.log("categorySelected.value", categorySelected.value);
  // try {
  //   await store.searchMojoNfts(categorySelected.value, "");
  // } catch (error) {
  //   console.log(error);
  // }
}

/* Watch for Category Changes */
watch(categorySelected, fetchData);

onMounted(async () => {
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
  await checkIfWalletIsConnected();
  await fetchMusicCategories();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#stream-content {
  position: relative;
  height: 100%;
  overflow: scroll;

  .bg-shape {
    background: #fff;
    background-image: url("./BlackCorner.png");
    background-repeat: no-repeat;
    background-position: center right;
    background-size: auto;
  }

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
      flex-direction: row;
      align-content: center;
      align-items: flex-start;
      justify-content: center;
      padding: 10px;
      overflow: scroll;

      @include breakpoint($break-ssm) {
        padding: 0;
        flex-direction: column;
        align-content: center;
        align-items: flex-start;
        justify-content: flex-start;
      }

      .left {
        width: 30%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        padding: 50px 20px 50px 50px;

        @include breakpoint($break-ssm) {
          width: 100%;
        }

        h2 {
          width: 100%;
          color: $white;
          font-size: 31px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: left;
          margin: 0;
        }

        ul.category-list {
          min-width: 300px;
          list-style-type: none;
          list-style-position: outside;
          margin-block-start: 0.5em;
          margin-block-end: 0;
          margin-inline-start: 0;
          margin-inline-end: 0;
          padding-inline-start: 0;
          border-top: 1px solid #1a1a1a;

          li {
            font-size: 22px;
            font-weight: 700;
            line-height: 1.7rem;
            padding-top: 0.7rem;
            padding-bottom: 0.5rem;
            padding-left: 1rem;
            padding-right: 1rem;
            border-bottom: 1px solid #1a1a1a;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: #fff;
              font-weight: 900;
            }
            &:focus {
              color: #fff;
              font-weight: 900;
            }
            &:active {
              color: #fff;
              font-weight: 900;
            }
          }
        }

        .li-active {
          color: #fff;
          font-weight: 900;
        }

        .category-list-play-button {
          margin: 0 5px -2px -15px;
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 50px 20px 60px 60px;

        @include breakpoint($break-ssm) {
          padding: 20px;
        }

        .track-list {
          width: 100%;
          max-width: 960px;
          display: inline-block;
          margin: 0 auto;
        }

        .dj-graphic {
          width: 100%;
          margin: 20px auto 0;
          padding: 0 10px;
          overflow: hidden;

          @include breakpoint($break-ssm) {
            padding: 0;
          }

          img,
          svg {
            width: 85%;
            height: auto;
            object-fit: cover;
            overflow: hidden;
          }
        }

        h2 {
          color: $white;
          font-size: 2rem;
          margin: 0;

          @include breakpoint($break-ssm) {
            font-size: 2.45rem;
          }
        }
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
    min-height: $page-height;
    display: flex;
    align-items: center;
  }
}
</style>
