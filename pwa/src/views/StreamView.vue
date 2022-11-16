<template>
  <section id="stream-content">
    <div class="main">
      <section id="stream">
        <div class="left">
          <h2>Find your groove</h2>
          <ul class="category-list">
            <li @click="selectCategory('')" :class="categorySelected === '' ? 'li-active' : ''">
              <PlayButtonWhite
                v-if="categorySelected === ''"
                class="category-list-play-button"
              />All
            </li>
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
            <div v-if="trackList" class="row token-list">
              <template v-for="token in trackList" :key="token.tokenId">
                <!-- <div class="nft" @click="loadMojoNFT(token.tokenId)"> -->
                <div class="nft">
                  <div
                    v-if="token.image && getUrlProtocol(token.image) === 'mp4'"
                    class="nft-video"
                  >
                    <video height="240" controls>
                      <source :src="`${token.image}`" type="video/mp4" />
                      <!-- <source :src="`${token.image}`" type="video/ogg" /> -->
                      Your browser does not support the video tag.
                    </video>
                  </div>
                  <div
                    v-else-if="token.image && getUrlProtocol(token.image) === 'mp3'"
                    class="nft-video"
                  >
                    <video height="240" controls>
                      <source :src="getUrlProtocol(token.image)" type="video/mp3" />
                      <!-- <source :src="`${image}`" type="video/ogg" /> -->
                      Your browser does not support the video tag.
                    </video>
                  </div>
                  <div v-else-if="token.image" class="nft-image">
                    <img :src="`${getUrlProtocol(token.image)}`" :alt="`${token.name}`" />
                  </div>
                  <div v-else class="nft-error-image">
                    <img src="../assets/images/ImageError.png" alt="No image" />
                  </div>
                  <div v-if="token.name" class="nft-title">
                    {{ token.tokenId }}. {{ token.name }}
                  </div>
                  <div v-else class="nft-title">Nameless</div>
                  <!-- <div v-if="token.contract" class="nft-title">Contract : {{ token.contract }}</div>
                  <div v-if="token.tokenId" class="nft-title">Token Id : {{ token.tokenId }}</div>
                  <div v-if="token.description" class="nft-description">
                    {{ token.description }}
                  </div>
                  <div v-if="token.external_url" class="nft-external-url">
                    {{ token.external_url }}
                  </div>
                  <div v-if="token.animation_url" class="nft-animation-url">
                    {{ token.animation_url }}
                  </div> -->
                  <div v-if="token.attributes" class="nft-attributes">
                    <template v-for="attr in token.attributes" :key="attr.value">
                      <div class="nft-attribute-cards">
                        <div class="nft-attribute-card">
                          <div class="nft-attribute-card-trait">
                            {{ attr.trait_type }} : {{ attr.value }}
                          </div>
                        </div>
                      </div>
                    </template>
                  </div>
                </div>
              </template>
            </div>
          </div>
          <div class="no-track-list" v-if="trackList.length === 0">
            <h2>Please be patient while we spin another mix...</h2>
            <div class="dj-graphic">
              <img src="../assets/images/DJ.png" alt="DJ Saved my Life" />
            </div>
          </div>
        </div>
      </section>
    </div>
  </section>
</template>
<script setup>
import { ref, watch, onMounted } from "vue";
import { Notyf } from "notyf";
/* Import our Pinia Store */
import { storeToRefs } from "pinia";
import { useStore } from "../store";
/* Import our diffeent Services */
import { generateLink } from "../services/helpers";
import tablelandCRUD from "../services/tablelandCRUD.js";
/* Components */
import PlayButtonWhite from "../components/icons/PlayButtonWhite.vue";
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
const categorySelected = ref("");
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
/* Select a new Category */
function selectCategory(category) {
  categorySelected.value = category.value;
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
/**
 * Fetch Mojo Creator NFT
 */
async function fetchMojoMusicNFTs() {
  store.setLoading(true);
  try {
    /* Load Tableland CRUD */
    const tableland = new tablelandCRUD();
    const mNFTs = await tableland.getMojoMusicNFTs();
    /* Load up our Token Data */
    mNFTs.forEach(async (nft) => {
      if (nft) {
        /* Mojo Creators NFT Form Metadata fields */
        let obj = {
          tokenId: nft[0] ? nft[0] : 0,
          name: nft[1] ? nft[1] : "",
          description: nft[2] ? nft[2] : "",
          image: nft[3] ? nft[3] : "",
          category: nft[4] ? nft[4] : "",
          external_url: nft[5] ? nft[5] : "",
          background_color: nft[6] ? nft[6] : "",
          animation_url: nft[7] ? nft[7] : "",
          youtube_url: nft[8] ? nft[8] : "",
        };
        /* Get our NFT metadata attributes */
        // const mcNFTattributes = tableland.getMojoCreatorNFTAttributes(nft.tokenId);
        /* Reset our Attributes for newly loaded NFT data */
        // if (mcNFTattributes) attributes.value = [];
        // mcNFTattributes.forEach((attribute) => {
        //   console.log(attribute);
        //   let obj = {
        //     maintable_tokenid: attribute[0],
        //     trait_id: attribute[1],
        //     icon: attribute[2],
        //     display_type: attribute[3],
        //     trait_type: attribute[4],
        //     value: attribute[5],
        //   };
        //   console.log("attributes.value BEFORE", attributes.value[0]);
        //   attributes.value.push(...[obj]);
        //   console.log("attributes.value AFTER", attributes.value[0]);
        // });
        store.addTrackList(...[obj]);
        return;
      }
    });
  } catch (error) {
    console.log("error", error);
    store.setLoading(false);
  }
}

/**
 * Search Mojo Creator NFT
 */
async function searchMojoMusicNFTs() {
  store.setLoading(true);
  try {
    /* Load Tableland CRUD */
    const tableland = new tablelandCRUD();
    let mNFTs = [];
    if (
      !categorySelected.value ||
      categorySelected.value === undefined ||
      categorySelected.value === ""
    ) {
      mNFTs = await tableland.getMojoMusicNFTs();
    } else {
      mNFTs = await tableland.searchMojoMusicNFTs(categorySelected.value);
    }
    /* Reset our Store List */
    store.resetTracks();
    /* Load up our Token Data */
    mNFTs.forEach(async (nft) => {
      if (nft) {
        /* Mojo Creators NFT Form Metadata fields */
        let obj = {
          tokenId: nft[0] ? nft[0] : 0,
          name: nft[1] ? nft[1] : "",
          description: nft[2] ? nft[2] : "",
          image: nft[3] ? nft[3] : "",
          category: nft[4] ? nft[4] : "",
          external_url: nft[5] ? nft[5] : "",
          background_color: nft[6] ? nft[6] : "",
          animation_url: nft[7] ? nft[7] : "",
          youtube_url: nft[8] ? nft[8] : "",
        };
        /* Get our NFT metadata attributes */
        // const mcNFTattributes = tableland.getMojoCreatorNFTAttributes(nft.tokenId);
        /* Reset our Attributes for newly loaded NFT data */
        // if (mcNFTattributes) attributes.value = [];
        // mcNFTattributes.forEach((attribute) => {
        //   console.log(attribute);
        //   let obj = {
        //     maintable_tokenid: attribute[0],
        //     trait_id: attribute[1],
        //     icon: attribute[2],
        //     display_type: attribute[3],
        //     trait_type: attribute[4],
        //     value: attribute[5],
        //   };
        //   console.log("attributes.value BEFORE", attributes.value[0]);
        //   attributes.value.push(...[obj]);
        //   console.log("attributes.value AFTER", attributes.value[0]);
        // });
        store.addTrackList(...[obj]);
        return;
      }
    });
  } catch (error) {
    console.log("error", error);
    store.setLoading(false);
  }
}

/* Checks what type of NFT we have image, mp3, mp4, etc. */
const getUrlProtocol = (url) => {
  let protocol = url.endsWith("mp4") ? 5 : 0;
  if (protocol == 0) protocol = url.endsWith("mp3") ? 6 : 0;
  if (protocol == 0) protocol = url.endsWith("gif") ? 7 : 0;
  if (protocol == 0) protocol = url.startsWith("http://") ? 1 : 0;
  if (protocol == 0) protocol = url.startsWith("https://") ? 2 : 0;
  if (protocol == 0) protocol = url.startsWith("ipfs://") ? 3 : 0;
  if (protocol == 0) protocol = url !== "" ? 4 : 0;
  switch (protocol) {
    case 1:
      return url;
    case 2:
      return url;
    case 3:
      return "https://ipfs.io/ipfs/" + url.substring(7);
    case 4:
      return generateLink(url);
    case 5:
      return "mp4";
    case 6:
      return "mp3";
    case 7:
      return url;
    case 0:
      return "Not http or https";
  }
};

/* Watch for Category Changes */
watch(categorySelected, searchMojoMusicNFTs);

onMounted(async () => {
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
  await checkIfWalletIsConnected();
  await fetchMusicCategories();
  await fetchMojoMusicNFTs();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#stream-content {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: scroll;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#stream {
      height: 100%;
      color: #212121;
      background: $mojo-blue;
      display: flex;
      flex-direction: row;
      align-content: center;
      align-items: flex-start;
      justify-content: center;
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
        padding: 40px 20px 40px 40px;

        @include breakpoint($break-ssm) {
          width: 100%;
        }

        h2 {
          width: 100%;
          color: $white;
          font-size: 34px;
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
            font-size: 19px;
            font-weight: 700;
            line-height: 1.4rem;
            padding-top: 0.6rem;
            padding-bottom: 0.3rem;
            padding-left: 1rem;
            padding-right: 1rem;
            border-bottom: 1px solid #1a1a1a;
            transition: 0.6s;
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
          .li-active {
            color: #fff;
            font-weight: 900;
          }

          .category-list-play-button {
            margin: 0 5px -2px -15px;
          }
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 40px 20px 40px 40px;

        @include breakpoint($break-ssm) {
          padding: 20px;
        }

        .track-list {
          width: 100%;
          max-width: 1200px;
          display: inline-block;
          margin: 0 auto;
          .row {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-content: center;
            justify-content: center;
            align-items: flex-start;
          }

          .token-list {
            position: relative;
            width: 97%;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            align-content: center;
            justify-content: center;
            align-items: flex-start;
            margin: 0 auto;

            /* Tablet Landscape */
            @include breakpoint($break-md) {
              grid-template-columns: repeat(3, 1fr);
            }
            /* Tablet Portrait LG */
            @include breakpoint($break-sm) {
              grid-template-columns: repeat(2, 1fr);
            }
            /* Tablet Portrait SML */
            @include breakpoint($break-ssm) {
              grid-template-columns: repeat(2, 1fr);
            }
            /* Smartphone */
            @include breakpoint($break-xs) {
              grid-template-columns: repeat(1, 1fr);
            }
            /* Old devices */
            @include breakpoint($break-xxs) {
              grid-template-columns: repeat(1, 1fr);
            }

            .nft {
              display: block;
              box-sizing: border-box;
              width: 100%;
              min-height: 240px;
              background: #f4f4f4;
              border-radius: 10px;
              overflow: hidden;
              cursor: pointer;

              .nft-video {
                width: 100%;
                margin: 0 auto;
                padding: 0;
                overflow: hidden;
                background: #f4f4f4;

                video {
                  width: 100%;
                  height: 100%;
                  object-fit: contain;
                  overflow: hidden;
                }
              }

              .nft-image {
                width: 100%;
                margin: 0 auto;
                padding: 0;
                overflow: hidden;

                img,
                svg {
                  display: block;
                  width: 100%;
                  height: 100%;
                  object-fit: contain;
                  overflow: hidden;
                }
              }

              .nft-error-image {
                width: 100%;
                margin: 15px auto 0;
                padding: 0;
                overflow: hidden;

                img,
                svg {
                  display: block;
                  width: 100%;
                  height: 100%;
                  object-fit: contain;
                  overflow: hidden;
                }
              }

              .nft-title {
                color: #1a1a1a;
                width: 100%;
                font-size: 14px;
                font-weight: normal;
                text-transform: uppercase;
                text-align: center;
                margin: 20px 0;
              }

              .nft-description {
                color: #1a1a1a;
                width: 100%;
                font-size: 14px;
                font-weight: normal;
                text-transform: uppercase;
                text-align: center;
                margin: 20px 0;
              }

              .nft-external-url {
                color: #1a1a1a;
                width: 100%;
                font-size: 14px;
                font-weight: normal;
                text-transform: uppercase;
                text-align: center;
                margin: 20px 0;
              }

              .nft-animation-url {
                color: #1a1a1a;
                width: 100%;
                font-size: 14px;
                font-weight: normal;
                text-transform: uppercase;
                text-align: center;
                margin: 20px 0;
              }
              .nft-attributes {
                color: #1a1a1a;
                width: 100%;
                font-size: 14px;
                font-weight: normal;
                text-align: center;
                margin: 10px auto 0;
                display: flex;
                flex-direction: row wrap;
                align-content: flex-start;
                justify-content: space-between;
                align-items: flex-start;
                overflow: scroll;

                .nft-attribute-card {
                  width: auto;
                  min-width: 60px;
                  min-height: 40px;
                  color: $black;
                  background-color: #fff;
                  border: 1px solid $mojo-blue;
                  border-radius: 10px;
                  letter-spacing: 1px;
                  font-size: 12px;
                  line-height: 20px;
                  margin: 0 5px 5px 5px;
                  padding: 10px;
                  text-align: left;

                  .nft-attribute-card-trait {
                    display: flex;
                    flex-direction: row wrap;
                    align-content: flex-start;
                    justify-content: space-between;
                    align-items: flex-start;
                  }
                }
              }
            }
          }
        }

        .no-track-list {
          width: 100%;
          display: inline-block;
          margin: 0 auto;

          h2 {
            color: $white;
            font-size: 34px;
            font-style: normal;
            font-weight: 700;
            line-height: 42px;
            margin: 0;

            @include breakpoint($break-ssm) {
              font-size: 1.5rem;
            }
          }

          .dj-graphic {
            width: 100%;
            margin: 20px auto 0;
            padding: 0 10px;
            overflow: hidden;

            @include breakpoint($break-sm) {
              padding: 0;
            }

            img,
            svg {
              display: block;
              width: 85%;
              height: auto;
              object-fit: cover;
              overflow: hidden;
              @include breakpoint($break-sm) {
                width: 85%;
              }
            }
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
