<template>
  <section id="content">
    <div class="main">
      <section id="collection">
        <div class="left">
          <h2>Chains</h2>
          <ul class="blockchain-list">
            <li
              v-for="chain of blockchains"
              :key="chain"
              @click="selectBlockchain(chain)"
              :class="chainSelected === chain.id ? 'li-active' : ''"
            >
              {{ chain.label }}
            </li>
          </ul>
        </div>
        <div class="right">
          <section id="explore">
            <div class="row">
              <div class="row-header">
                <h2>ethereum</h2>
              </div>
              <div v-if="ethereumTokens && ethereumTokens.length > 0" class="row token-list">
                <template v-for="token in ethereumTokens" :key="token.tokenId">
                  <NftCard
                    :contract="token.contract"
                    :tokenId="token.tokenId"
                    :type="token.type"
                    :name="
                      token.metadata && token.metadata.name
                        ? token.metadata.name
                        : token.metadata && token.metadata.title
                        ? token.metadata.title
                        : ''
                    "
                    :image="token.metadata && token.metadata.image"
                    :description="
                      token.metadata && token.metadata.description ? token.metadata.description : ''
                    "
                    :external_url="token.metadata.external_url"
                    :animation_url="token.metadata.animation_url"
                    :attributes="token.metadata.attributes"
                  />
                </template>
              </div>
            </div>
            <div class="row">
              <div class="row-header">
                <h2>polygon</h2>
              </div>
              <div v-if="polygonTokens && polygonTokens.length > 0" class="row token-list">
                <template v-for="(index, token) in polygonTokens" :key="index">
                  <NftCard
                    :contract="token.contract"
                    :tokenId="token.tokenId"
                    :type="token.type"
                    :name="
                      token.metadata && token.metadata.name
                        ? token.metadata.name
                        : token.metadata && token.metadata.title
                        ? token.metadata.title
                        : ''
                    "
                    :image="
                      token.metadata && token.metadata.image
                        ? token.metadata.image
                        : token.metadata && token.metadata.imageUrl
                        ? token.metadata.imageUrl
                        : ''
                    "
                    :description="
                      token.metadata && token.metadata.description ? token.metadata.description : ''
                    "
                    :external_url="
                      token.metadata && token.metadata.external_url
                        ? token.metadata.external_url
                        : ''
                    "
                    :animation_url="
                      token.metadata && token.metadata.animation_url
                        ? token.metadata.animation_url
                        : ''
                    "
                    :attributes="
                      token.metadata && token.metadata.attributes ? token.metadata.attributes : []
                    "
                  />
                </template>
              </div>
            </div>
            <div class="row">
              <div class="row-header">
                <h2>optimism</h2>
              </div>
              <div v-if="optimismTokens && optimismTokens.length > 0" class="row token-list">
                <template v-for="(index, token) in optimismTokens" :key="index">
                  <NftCard
                    :contract="token.contract"
                    :tokenId="token.tokenId"
                    :type="token.type"
                    :name="
                      token.metadata && token.metadata.name
                        ? token.metadata.name
                        : token.metadata && token.metadata.title
                        ? token.metadata.title
                        : ''
                    "
                    :image="
                      token.metadata && token.metadata.image
                        ? token.metadata.image
                        : token.metadata && token.metadata.imageUrl
                        ? token.metadata.imageUrl
                        : ''
                    "
                    :description="
                      token.metadata && token.metadata.description ? token.metadata.description : ''
                    "
                    :external_url="
                      token.metadata && token.metadata.external_url
                        ? token.metadata.external_url
                        : ''
                    "
                    :animation_url="
                      token.metadata && token.metadata.animation_url
                        ? token.metadata.animation_url
                        : ''
                    "
                    :attributes="
                      token.metadata && token.metadata.attributes ? token.metadata.attributes : []
                    "
                  />
                </template>
              </div>
            </div>
            <div class="row">
              <div class="row-header">
                <h2>arbitrum</h2>
              </div>
              <div v-if="arbitrumTokens && arbitrumTokens.length > 0" class="row token-list">
                <template v-for="(index, token) in arbitrumTokens" :key="index">
                  <NftCard
                    :contract="token.contract"
                    :tokenId="token.tokenId"
                    :type="token.type"
                    :name="
                      token.metadata && token.metadata.name
                        ? token.metadata.name
                        : token.metadata && token.metadata.title
                        ? token.metadata.title
                        : ''
                    "
                    :image="
                      token.metadata && token.metadata.image
                        ? token.metadata.image
                        : token.metadata && token.metadata.imageUrl
                        ? token.metadata.imageUrl
                        : ''
                    "
                    :description="
                      token.metadata && token.metadata.description ? token.metadata.description : ''
                    "
                    :external_url="
                      token.metadata && token.metadata.external_url
                        ? token.metadata.external_url
                        : ''
                    "
                    :animation_url="
                      token.metadata && token.metadata.animation_url
                        ? token.metadata.animation_url
                        : ''
                    "
                    :attributes="
                      token.metadata && token.metadata.attributes ? token.metadata.attributes : []
                    "
                  />
                </template>
              </div>
            </div>
            <div class="row">
              <div class="row-header">
                <h2>avalanche</h2>
              </div>
              <div v-if="avalancheTokens && avalancheTokens.length > 0" class="row token-list">
                <template v-for="(index, token) in avalancheTokens" :key="index">
                  <NftCard
                    :contract="token.contract"
                    :tokenId="token.tokenId"
                    :type="token.type"
                    :name="
                      token.metadata && token.metadata.name
                        ? token.metadata.name
                        : token.metadata && token.metadata.title
                        ? token.metadata.title
                        : ''
                    "
                    :image="
                      token.metadata && token.metadata.image
                        ? token.metadata.image
                        : token.metadata && token.metadata.imageUrl
                        ? token.metadata.imageUrl
                        : ''
                    "
                    :description="
                      token.metadata && token.metadata.description ? token.metadata.description : ''
                    "
                    :external_url="
                      token.metadata && token.metadata.external_url
                        ? token.metadata.external_url
                        : ''
                    "
                    :animation_url="
                      token.metadata && token.metadata.animation_url
                        ? token.metadata.animation_url
                        : ''
                    "
                    :attributes="
                      token.metadata && token.metadata.attributes ? token.metadata.attributes : []
                    "
                  />
                </template>
              </div>
            </div>
          </section>
        </div>
      </section>
    </div>
  </section>
</template>
<script setup>
import { ref, onMounted } from "vue";
import { Notyf } from "notyf";

/* Import our Pinia Store */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Import our Services and APIs */
import authNFT from "../services/authNFT.js";
import alchemyApi from "../services/alchemyApi.js";

/* Components */
import NftCard from "@/components/NftCard.vue";

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

/* Init Store and Refs */
const store = useStore();
const { account, ethereumTokens, polygonTokens, optimismTokens, arbitrumTokens, avalancheTokens } =
  storeToRefs(store);

/* Local Variables */
const chainSelected = ref(1);

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
    if (accounts.length !== 0) {
      store.updateAccount(accounts[0]);
      await fetchTokens();
    }
  } catch (error) {
    console.log(error);
  }
}

/* Select Blockchain */
const blockchains = ref([
  { id: 1, value: "ethereum", label: "Ethereum" },
  { id: 2, value: "polygon", label: "Polygon" },
  { id: 3, value: "optimisim", label: "Optimisim" },
  { id: 4, value: "arbitrum", label: "Arbitrum" },
  { id: 5, value: "avalanche", label: "Avalanche" },
  { id: 7, value: "all", label: "All" },
]);
/* Select a new Chain */
function selectBlockchain(category) {
  chainSelected.value = category.id;
  console.log("Chain Selected :", chainSelected.value);
}

/* Fetch NFT by Account Address */
async function fetchTokens() {
  {
    {
      account.value;
    }
  }
  if (account.value) {
    try {
      const authAccount = new authNFT();
      /* Ethereum */
      if (ethereumTokens.value.length === 0) {
        let ethereumTokens = await authAccount.fetchAccountNfts(1, account.value);
        store.addEthereumTokens(...ethereumTokens);
        let ethereumTestnetTokens = await authAccount.fetchAccountNfts(5, account.value);
        store.addEthereumTokens(...ethereumTestnetTokens);
      }

      /* Polygon */
      if (polygonTokens.value.length === 0) {
        let polygonTokens = await authAccount.fetchAccountNfts(137, account.value);
        store.addPolygonTokens(...polygonTokens);
        let polygonTestnetTokens = await authAccount.fetchAccountNfts(80001, account.value);
        store.addPolygonTokens(...polygonTestnetTokens);
      }

      /* We use Alchemy API for Optimisim and Arbitrum */
      const authAlchemyAccount = new alchemyApi();

      /* Optimism */
      if (optimismTokens.value.length === 0) {
        let optimismTokens = await authAlchemyAccount.fetchAccountNfts(10, account.value);
        store.addOptimismTokens(...optimismTokens);
      }

      /* Arbitrum */
      if (arbitrumTokens.value.length === 0) {
        let arbitrumTokens = await authAlchemyAccount.fetchAccountNfts(42161, account.value);
        store.addArbitrumTokens(...arbitrumTokens);
      }

      /* Avalanche */
      // if (avalancheTokens.value.length === 0) {
      //   let avalancheTokens = await authAccount.fetchAccountNfts(42161, account.value);
      //   store.addAvalancheTokens(...avalancheTokens);
      // }
    } catch (error) {
      console.log(`Error fetching tokens, please refresh to try again!`);
    }
  }
}

onMounted(async () => {
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
  await checkIfWalletIsConnected();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#content {
  position: relative;
  height: 100%;
  overflow: scroll;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#collection {
      height: 100%;
      color: #212121;
      background: #1c8bfe;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 0 10px;
      overflow: scroll;

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
        padding: 0;

        .row-header {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: flex-start;
          justify-content: center;
          align-items: center;
          margin: 0;

          h2 {
            width: 100%;
            color: $black;
            font-style: normal;
            font-weight: 700;
            font-size: 36px;
            line-height: 42px;
            text-align: left;
            margin: 0;
          }
        }

        .row {
          width: 100%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: center;
          align-items: flex-start;
          padding: 0;
        }

        .token-list {
          width: 100%;
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 15px;
          align-content: center;
          justify-content: center;
          align-items: flex-start;
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

      ul.blockchain-list {
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

      .blockchain-list-play-button {
        margin: 0 5px 0 -15px;
      }
    }
  }
}

body.dark-theme {
  section#content .main section#collection .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .collection {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
