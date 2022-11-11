<template>
  <section id="collection-content">
    <div class="main">
      <section id="collection">
        <div class="left">
          <h2>Blockchains</h2>
          <ul class="blockchain-list">
            <li
              v-for="chain of blockchains"
              :key="chain.id"
              @click="selectBlockchain(chain)"
              :class="chainSelected === chain.value ? 'li-active' : ''"
            >
              <PlayButtonWhite
                v-if="chainSelected === chain.value"
                class="blockchain-list-play-button"
              />{{ chain.label }}
            </li>
          </ul>
        </div>
        <div class="right">
          <div v-if="chainSelected === 'all' || chainSelected === 'ethereum'" class="row">
            <div class="row-header">
              <h2>Ethereum</h2>
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
                  :image="
                    token.metadata && token.metadata.image
                      ? token.metadata.image
                      : token.tokenUri && token.tokenUri.raw
                      ? token.tokenUri.raw
                      : ''
                  "
                  :description="
                    token.metadata && token.metadata.description ? token.metadata.description : ''
                  "
                  :external_url="
                    token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
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
            <div v-else class="row no-results">
              No results found...please try another blockchain
            </div>
          </div>
          <div v-if="chainSelected === 'all' || chainSelected === 'polygon'" class="row">
            <div class="row-header">
              <h2>Polygon</h2>
            </div>
            <div v-if="polygonTokens && polygonTokens.length > 0" class="row token-list">
              <template v-for="token in polygonTokens" :key="token.tokenId">
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
                      : token.tokenUri && token.tokenUri.raw
                      ? token.tokenUri.raw
                      : ''
                  "
                  :description="
                    token.metadata && token.metadata.description ? token.metadata.description : ''
                  "
                  :external_url="
                    token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
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
            <div v-else class="row no-results">
              No results found...please try another blockchain
            </div>
          </div>
          <div v-if="chainSelected === 'all' || chainSelected === 'optimism'" class="row">
            <div class="row-header">
              <h2>Optimism</h2>
            </div>
            <div v-if="optimismTokens && optimismTokens.length > 0" class="row token-list">
              <template v-for="token in optimismTokens" :key="token.tokenId">
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
                      : token.tokenUri && token.tokenUri.raw
                      ? token.tokenUri.raw
                      : ''
                  "
                  :description="
                    token.metadata && token.metadata.description ? token.metadata.description : ''
                  "
                  :external_url="
                    token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
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
            <div v-else class="row no-results">
              No results found...please try another blockchain
            </div>
          </div>
          <div v-if="chainSelected === 'all' || chainSelected === 'arbitrum'" class="row">
            <div class="row-header">
              <h2>Arbitrum</h2>
            </div>
            <div v-if="arbitrumTokens && arbitrumTokens.length > 0" class="row token-list">
              <template v-for="token in arbitrumTokens" :key="token.tokenId">
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
                      : token.tokenUri && token.tokenUri.raw
                      ? token.tokenUri.raw
                      : ''
                  "
                  :description="
                    token.metadata && token.metadata.description ? token.metadata.description : ''
                  "
                  :external_url="
                    token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
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
            <div v-else class="row no-results">
              No results found...please try another blockchain
            </div>
          </div>
          <div v-if="chainSelected === 'all' || chainSelected === 'avalanche'" class="row">
            <div class="row-header">
              <h2>Avalanche</h2>
            </div>
            <div v-if="avalancheTokens && avalancheTokens.length > 0" class="row token-list">
              <template v-for="token in avalancheTokens" :key="token.tokenId">
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
                      : token.tokenUri && token.tokenUri.raw
                      ? token.tokenUri.raw
                      : ''
                  "
                  :description="
                    token.metadata && token.metadata.description ? token.metadata.description : ''
                  "
                  :external_url="
                    token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
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
            <div v-else class="row no-results">
              No results found...please try another blockchain
            </div>
          </div>
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
import PlayButtonWhite from "../components/icons/PlayButtonWhite.vue";
import NftCard from "../components/NftCard.vue";

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
const chainSelected = ref("ethereum");

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
  { id: 1, value: "ethereum", label: "ethereum" },
  { id: 2, value: "polygon", label: "polygon" },
  { id: 3, value: "optimism", label: "optimism" },
  { id: 4, value: "arbitrum", label: "arbitrum" },
  { id: 5, value: "avalanche", label: "avalanche" },
  { id: 7, value: "all", label: "all" },
]);
/* Select a new Chain */
function selectBlockchain(category) {
  chainSelected.value = category.value;
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
        // let ethereumTestnetTokens = await authAccount.fetchAccountNfts(5, account.value);
        // store.addEthereumTokens(...ethereumTestnetTokens);
      }

      /* Polygon */
      if (polygonTokens.value.length === 0) {
        let polygonTokens = await authAccount.fetchAccountNfts(137, account.value);
        store.addPolygonTokens(...polygonTokens);
        // let polygonTestnetTokens = await authAccount.fetchAccountNfts(80001, account.value);
        // store.addPolygonTokens(...polygonTestnetTokens);
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
      if (avalancheTokens.value.length === 0) {
        let avalancheTokens = await authAccount.fetchAccountNfts(42161, account.value);
        store.addAvalancheTokens(...avalancheTokens);
      }
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

section#collection-content {
  position: relative;
  height: 100%;
  overflow: scroll;
  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#collection {
      width: 100%;
      height: 100%;
      color: #212121;
      background: $mojo-blue;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: row;
      align-content: center;
      align-items: flex-start;
      justify-content: center;
      overflow: scroll;

      @include breakpoint($break-ssm) {
        flex-direction: column;
        align-content: center;
        align-items: center;
        justify-content: flex-start;
      }

      .left {
        width: 27%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        padding: 45px 0 40px 30px;

        @include breakpoint($break-ssm) {
          width: 100%;
          padding: 40px 0 40px 40px;
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
          padding-left: 1rem;
        }

        ul.blockchain-list {
          min-width: 260px;
          list-style-type: none;
          list-style-position: outside;
          margin-block-start: 0.5em;
          margin-block-end: 0;
          margin-inline-start: 0;
          margin-inline-end: 0px;
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
              color: $white;
              font-weight: 900;
            }
            &:focus {
              color: #fff;
              font-weight: 900;
            }
            &:active {
              color: $white;
              font-weight: 900;
            }
          }
        }

        .li-active {
          color: #fff;
          font-weight: 900;
        }

        .blockchain-list-play-button {
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
        padding: 0 20px 40px;

        .row-header {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: flex-start;
          justify-content: center;
          align-items: center;
          margin: 50px 0 0 0;

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
          grid-template-columns: repeat(4, 1fr);
          gap: 30px;
          align-content: center;
          justify-content: center;
          align-items: flex-start;

          /* Tablet Landscape */
          @include breakpoint($break-md) {
            grid-template-columns: repeat(3, 1fr);
          }
          /* Tablet Portrait LG */
          @include breakpoint($break-sm) {
            grid-template-columns: repeat(3, 1fr);
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
        }

        .no-results {
          width: 100%;
          color: $white;
          font-size: 24px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: left;
          margin: 0;
        }
      }
    }
  }
}

body.dark-theme {
  section#collection-content .main section#collection .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  #collection {
    min-height: $page-height;
    display: flex;
    align-items: center;
  }
}
</style>
