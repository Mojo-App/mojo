<template>
  <section id="explore-content">
    <div class="main">
      <section id="search-bar">
        <div class="row">
          <div class="search">
            <button :class="!show ? 'show-button' : 'hide-button'" @click="show = !show">
              {{ !show ? "show" : "hide" }}
            </button>
            <input
              type="text"
              v-model="contract"
              class="search-contract"
              placeholder="filter by contract"
            />
            <input
              type="text"
              v-model="name"
              class="search-name"
              placeholder="search by NFT name"
            />
            <select class="search-chain" v-model="chain">
              <option v-for="option in options" :value="option.label" :key="option.key">
                {{ option.text }}
              </option>
            </select>
            <button class="search-button-name" @click="searchTokens('name')" title="Search">
              search
            </button>
            <button
              v-if="showAdvancedSearch"
              class="show-advanced-button"
              @click="showAdvancedSearch = !showAdvancedSearch"
              title="Show advanced search"
            >
              <ArrowDownWhite class="arrow-down-small" />
            </button>
            <button
              v-if="!showAdvancedSearch"
              class="hide-advanced-button"
              @click="showAdvancedSearch = !showAdvancedSearch"
              title="Hide advanced search"
            >
              <ArrowDownWhite class="arrow-down-small" />
            </button>
            <button class="search-clear-button" @click="clearSearch()" title="Clear search">
              X
            </button>
          </div>
          <!-- Advanced Search Options Panel -->
          <div v-if="showAdvancedSearch" class="advanced-search">
            <input
              type="text"
              v-model="contractFilter"
              class="search-advanced-contract"
              placeholder="filter out contract address"
            />
            <input
              type="text"
              v-model="tokenId"
              class="search-tokenId"
              placeholder="find duplicate by token id"
            />
            <button
              class="search-button-advanced"
              @click="searchTokens('tokenId')"
              title="Find duplicates"
              :disabled="!tokenId"
            >
              go
            </button>
            <input
              type="text"
              v-model="duplicateUrl"
              class="search-duplicates"
              placeholder="find duplicate NFTS by image url"
            />
            <button
              class="search-button-advanced"
              @click="searchTokens('image')"
              title="Find duplicates"
              :disabled="!duplicateUrl"
            >
              go
            </button>
          </div>
          <!-- END Advanced Search Options Panel -->
          <!-- Mobile Buttons Row -->
          <div class="mobile-buttons">
            <div class="search-mobile-buttons">
              <button
                :class="!show ? 'show-button-mobile' : 'hide-button-mobile'"
                @click="show = !show"
              >
                {{ !show ? "show" : "hide" }}
              </button>
              <button
                v-if="showAdvancedSearch"
                class="show-advanced-button-mobile"
                @click="showAdvancedSearch = !showAdvancedSearch"
                title="Show advanced search"
              >
                advanced
              </button>
              <button
                v-if="!showAdvancedSearch"
                class="hide-advanced-button-mobile"
                @click="showAdvancedSearch = !showAdvancedSearch"
                title="Hide advanced search"
              >
                advanced
              </button>
              <button
                class="search-button-name-mobile"
                @click="searchTokens('name')"
                title="Search"
              >
                search name
              </button>
            </div>
            <div class="search-mobile-buttons">
              <button
                class="search-button-advanced-mobile"
                @click="searchTokens('tokenId')"
                title="Find duplicates"
                :disabled="!tokenId"
              >
                search id
              </button>
              <button
                class="search-button-advanced-mobile"
                @click="searchTokens('image')"
                title="Find duplicates"
                :disabled="!duplicateUrl"
              >
                search url
              </button>
              <button
                class="search-clear-button-mobile"
                @click="clearSearch()"
                title="Clear search"
              >
                clear
              </button>
            </div>
          </div>
        </div>
        <!-- END Mobile Buttons Row -->
      </section>
      <Transition name="slide-fade">
        <section v-show="show" id="search-results">
          <div class="search-results-row">
            <h2>Search Results</h2>
            <div
              v-if="(!loading && errorCode) || errorStatus || errorMessage"
              class="row error-box"
            >
              <!-- <div class="error-status">{{ errorCode }} : {{ errorStatus }}</div> -->
              <div class="error-message">
                {{ errorMessage
                }}<template v-if="errorStatus === 404"
                  ><br />Please make sure you have entered the correct contract address<br />
                  or try a different name or image url</template
                >
              </div>
            </div>
            <div v-if="searchResults" class="row token-list">
              <template v-for="token in searchResults" :key="token.token_id">
                <SearchCard :token="token" />
              </template>
              <div v-if="loading" class="loading-bar">...loading</div>
            </div>
          </div>
        </section>
      </Transition>
      <section id="marketplace">
        <div class="row-header">
          <h2>beats<span class="mojo-black">on</span>blocks</h2>
        </div>
        <div class="row token-list">
          <template v-for="token in latestTokens" :key="token.token_id">
            <NftCard
              :contract="token.contract_address"
              :tokenId="token.token_id"
              :type="token.type"
              :name="
                token.metadata && token.metadata.name
                  ? token.metadata.name
                  : token.metadata && token.metadata.title
                  ? token.metadata.title
                  : ''
              "
              :image="
                token.cached_animation_url
                  ? token.cached_animation_url
                  : token.cached_file_url
                  ? token.cached_file_url
                  : token.image
                  ? token.image
                  : ''
              "
              :description="
                token.metadata && token.metadata.description ? token.metadata.description : ''
              "
              :external_url="
                token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
              "
              :animation_url="
                token.metadata && token.metadata.animation_url ? token.metadata.animation_url : ''
              "
              :attributes="
                token.metadata && token.metadata.attributes ? token.metadata.attributes : []
              "
            />
          </template>
        </div>
        <div class="row-header">
          <h2>top<span class="mojo-black">pics</span></h2>
        </div>
        <div class="row token-list">
          <template v-for="token in topTokens" :key="token.token_id">
            <NftCard
              :contract="token.contract_address"
              :tokenId="token.token_id"
              :type="token.type"
              :name="
                token.metadata && token.metadata.name
                  ? token.metadata.name
                  : token.metadata && token.metadata.title
                  ? token.metadata.title
                  : ''
              "
              :image="
                token.cached_animation_url
                  ? token.cached_animation_url
                  : token.cached_file_url
                  ? token.cached_file_url
                  : token.image
                  ? token.image
                  : ''
              "
              :description="
                token.metadata && token.metadata.description ? token.metadata.description : ''
              "
              :external_url="
                token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
              "
              :animation_url="
                token.metadata && token.metadata.animation_url ? token.metadata.animation_url : ''
              "
              :attributes="
                token.metadata && token.metadata.attributes ? token.metadata.attributes : []
              "
            />
          </template>
        </div>
        <div class="row-header">
          <h2>trendy<span class="mojo-black">tunes</span></h2>
        </div>
        <div class="row token-list">
          <template v-for="token in trendingTokens" :key="token.token_id">
            <NftCard
              :contract="token.contract_address"
              :tokenId="token.token_id"
              :type="token.type"
              :name="
                token.metadata && token.metadata.name
                  ? token.metadata.name
                  : token.metadata && token.metadata.title
                  ? token.metadata.title
                  : ''
              "
              :image="
                token.cached_animation_url
                  ? token.cached_animation_url
                  : token.cached_file_url
                  ? token.cached_file_url
                  : token.image
                  ? token.image
                  : ''
              "
              :description="
                token.metadata && token.metadata.description ? token.metadata.description : ''
              "
              :external_url="
                token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
              "
              :animation_url="
                token.metadata && token.metadata.animation_url ? token.metadata.animation_url : ''
              "
              :attributes="
                token.metadata && token.metadata.attributes ? token.metadata.attributes : []
              "
            />
          </template>
        </div>
      </section>
    </div>
  </section>
</template>
<script setup>
import { ref, onMounted } from "vue";
import { Notyf } from "notyf";
/* Import our Pinia Store & Refs */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Import SVG */
import ArrowDownWhite from "../assets/svgs/ArrowDownWhite.vue?component";

/* Components */
import NftCard from "@/components/NftCard.vue";
import SearchCard from "@/components/SearchCard.vue";

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
/* Init Store Values and Methods */
const store = useStore();
const {
  loading,
  errorCode,
  errorStatus,
  errorMessage,
  searchResults,
  topTokens,
  latestTokens,
  trendingTokens,
} = storeToRefs(store);

const chain = ref("all");
const options = ref([
  { value: 0, label: "all", text: "all" },
  { value: 1, label: "ethereum", text: "ethereum" },
  // { value: 5, label: "ethereum-testnet", text: "Ethereum Testnet" },
  { value: 137, label: "polygon", text: "polygon" },
  // { value: 80001, label: "polygon-testnet", text: "Mumbai Testnet" },
  { value: 10, label: "optimism", text: "optimism" },
  // { value: 69, label: "optimism-testnet", text: "Optimism Testnet" },
  { value: 42161, label: "arbitrum", text: "arbitrum" },
  // { value: 421611, label: "arbitrum-testnet", text: "Arbitrum Testnet" },
  { value: 43114, label: "avalanche", text: "avalanche" },
  // { value: 421611, label: "avalanche-testnet", text: "Arbitrum Testnet" },
]);

/* Show Search Results Panel */
const show = ref(false);
const showAdvancedSearch = ref(false);

/* 🦸🏻 NFT Port Search Defaults */
const contract = ref("");
const contractFilter = ref("");
const tokenId = ref(null);
const name = ref("");
const image = ref("");
const duplicateUrl = ref("");
const sort_order = ref("asc");
const order_by = ref("relevance");
const page_size = ref(50);
const page_number = ref(1);
const threshold = ref(0.1);

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

/**
 * Fetch NFTs using 🦸🏻 NFT Port API for our Marketplace Example
 */
async function fetchTokens() {
  if (topTokens.value.length === 0) {
    try {
      let topTokens = await store.contractNftSearch(
        "0xf12fd10f278c1fb29a62d6338d050cf2832f8080",
        "ethereum",
        "metadata",
        "true",
        8,
        1
      );
      if (topTokens.nfts && topTokens.total > 0) {
        store.addTopTokens(...topTokens.nfts);
      }
    } catch (error) {
      console.log(error);
    }
  }

  if (latestTokens.value.length === 0) {
    try {
      let latestTokens = await store.contractNftSearch(
        "0x317cb9eb5e2fdbfe4a58a3750a34136729b11280",
        "ethereum",
        "metadata",
        "true",
        4,
        1
      );
      if (latestTokens.nfts && latestTokens.total > 0) {
        store.addLatestTokens(...latestTokens.nfts);
      }
    } catch (error) {
      console.log(error);
    }
  }

  if (trendingTokens.value.length === 0) {
    try {
      let trendingTokens = await store.contractNftSearch(
        "0xef44e83db68b9e6df9ce6cc9343653c733762617",
        "ethereum",
        "metadata",
        "true",
        8,
        1
      );
      if (trendingTokens.nfts) {
        store.addTrendingTokens(...trendingTokens.nfts);
      }
    } catch (error) {
      console.log(error);
    }
  }
}

/**
 * NFTPort Search
 */
/* Fetch new NFT audio/media by Category or Name */
async function searchTokens(type) {
  /* Set Loading */
  store.setLoading(true);

  /* Clear our last response from Pinia Store */
  store.setErrorCode(null);
  store.setErrorStatus(null);
  store.setErrorMessage("");

  /* Open the Search Panel */
  if (show.value === false) {
    show.value = true;
  }

  console.log("Search type:", type);

  if (type === "name") {
    console.log("contract:", contract.value);
    console.log("name:", name.value);
    console.log("chain:", chain.value);
    console.log("sort_order:", sort_order.value);
    console.log("order_by:", order_by.value);
    console.log("page_size:", page_size.value);
    console.log("page_number:", page_number.value);

    /* Name Search */
    try {
      const results = await store.searchNFTs(
        contract.value,
        name.value,
        chain.value,
        sort_order.value,
        order_by.value,
        page_size.value,
        page_number.value
      );

      const stylesResults = ["color: black", "background: grey"].join(";");
      console.log(
        "%c🦸🏻 NFT Port Search by Name fetched : %s",
        stylesResults,
        JSON.stringify(results)
      );

      if (results.search_results && results.search_results.length > 0) {
        store.addSearchResults(...results.search_results);
      }
      store.setLoading(false);
    } catch (error) {
      console.log(error);
      store.setLoading(false);
    }
  } else if (type === "image") {
    console.log("Contract Address :", contract.value);
    console.log("Contract Filter Address :", contractFilter.value);
    console.log("Duplicate Url :", duplicateUrl.value);
    console.log("Page Size :", page_size.value);
    console.log("Page Number :", page_number.value);
    console.log("Threshold :", page_number.value);
    /* Image Search */
    try {
      const results = await store.searchNFTImage(
        contractFilter.value,
        duplicateUrl.value,
        page_size.value,
        page_number.value,
        threshold.value
      );

      const stylesResults = ["color: black", "background: grey"].join(";");
      console.log(
        "%c🦸🏻 NFT Port Search by Image URL : %s",
        stylesResults,
        JSON.stringify(results, 0, 4)
      );

      if (results.is_similar && results.similar_nfts && results.similar_nfts.length > 0) {
        store.addSearchResults(...results.search_results);
      }
      if (!results.is_similar) {
        store.setErrorCode(404);
        store.setErrorStatus("NOT_FOUND");
        store.setErrorMessage("No similar results found!");
      }
      store.setLoading(false);
    } catch (error) {
      console.log(error);
      store.setLoading(false);
    }
  } else if (type === "tokenId") {
    console.log("chain:", chain.value);
    console.log("contract:", contract.value);
    console.log("contractFilter:", contractFilter.value);
    console.log("name:", name.value);
    console.log("tokenId:", tokenId.value);
    console.log("page_size:", page_size.value);
    console.log("page_number:", page_number.value);
    /* Token Id Search */
    try {
      const results = await store.searchNFTTokenId(
        contract.value,
        contractFilter.value,
        tokenId.value,
        name.value,
        chain.value,
        page_size.value,
        page_number.value,
        threshold.value
      );

      const stylesResults = ["color: black", "background: grey"].join(";");
      console.log(
        "%c🦸🏻 NFT Port Search by Token Id : %s",
        stylesResults,
        JSON.stringify(results, 0, 4)
      );

      if (results.is_similar && results.similar_nfts && results.similar_nfts.length > 0) {
        store.addSearchResults(...results.search_results);
      }
      if (!results.is_similar) {
        store.setErrorCode(404);
        store.setErrorStatus("NOT_FOUND");
        store.setErrorMessage("No similar results found!");
      }
      store.setLoading(false);
    } catch (error) {
      console.log(error);
      store.setLoading(false);
    }
  }
}

/* Clear our Search Results */
function clearSearch() {
  store.setErrorCode(null);
  store.setErrorStatus(null);
  store.setErrorMessage("");
  chain.value = "all";
  contract.value = "";
  contractFilter.value = "";
  tokenId.value = "";
  name.value = "";
  image.value = "";
  duplicateUrl.value = "";
  sort_order.value = "asc";
  order_by.value = "relevance";
  page_size.value = 50;
  page_number.value = 1;
}

onMounted(async () => {
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
  await checkIfWalletIsConnected();
  await fetchTokens();
});
</script>
<style lang="scss">
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#explore-content {
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
    flex-direction: column;
    align-content: center;
    align-items: center;
    justify-content: center;

    section#search-bar {
      color: $black;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: auto;
      display: inline-block;
      margin: 0 auto;
      padding: 20px 0 0 0;
      border-bottom: 1px solid #ffffff;

      @include breakpoint($break-md) {
        margin: 1em auto;
        padding: 0;
      }
      @include breakpoint($break-sm) {
        margin: 0 auto;
        padding: 0;
      }
      @include breakpoint($break-xs) {
        margin: 0 auto;
        padding: 0;
      }

      .row {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 0;

        h2 {
          font-size: 34px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: center;
          margin-block-start: 0;
          margin-block-end: 0.2em;
        }

        .search {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: center;
          justify-content: center;
          align-items: center;
          @include breakpoint($break-lg) {
            width: 100%;
            margin: 0 auto;
            padding-left: 3px;
          }
          @include breakpoint($break-md) {
            width: 100%;
            height: auto;
            margin: 0 auto;
          }
          @include breakpoint($break-sm) {
            width: 100%;
            flex-direction: column;
            height: auto;
            margin: 0 auto;
          }
          @include breakpoint($break-xs) {
            width: 100%;
            flex-direction: column;
            height: auto;
            margin: 0 auto;
          }
          select.search-chain {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            width: 200px;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            cursor: pointer;
            @include breakpoint($break-md) {
              width: 180px;
              margin: 0 1% 1% 1%;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
          }
          select.search-chain::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          select.search-chain:focus {
            border: 1px solid $black;
            outline: none;
          }

          /* Filter by Contract */
          input.search-contract {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            min-width: 400px;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            @include breakpoint($break-lg) {
              min-width: 256px;
            }
            @include breakpoint($break-md) {
              min-width: 200px;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
          }
          input.search-contract::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          input.search-contract:focus {
            border: 1px solid $black;
            outline: none;
          }

          /* Search by Token Name or Description */
          input.search-name {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            min-width: 220px;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            @include breakpoint($break-md) {
              min-width: 200px;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
          }
          input.search-name::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          input.search-name:focus {
            border: 1px solid $black;
            outline: none;
          }

          /* Search by Token Name or Description */
          input.search-image {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            width: auto;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            @include breakpoint($break-md) {
              min-width: 200px;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1%;
            }
          }
          input.search-image::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          input.search-image:focus {
            border: 1px solid $black;
            outline: none;
          }
          /* Desktopn & Tablet Versions */
          .search-button-name {
            color: $white;
            background-color: $mojo-blue;
            border: 0;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 14px;
            min-width: 100px;
            padding: 10px;
            text-align: center;
            margin: 0 5px;
            transition: 0.6s;
            cursor: pointer;
            display: inline-block;
            &:hover {
              color: $black;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
          }
          .show-button {
            color: $white;
            background-color: $mojo-blue;
            border: 0;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 14px;
            min-width: 70px;
            padding: 10px;
            text-align: center;
            margin-right: 5px;
            transition: 0.6s;
            cursor: pointer;
            display: inline-block;
            &:hover {
              color: $black;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
          }
          .hide-button {
            color: $white;
            background-color: $black;
            border: 0;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 14px;
            min-width: 70px;
            padding: 10px;
            text-align: center;
            margin-right: 5px;
            cursor: pointer;
            display: inline-block;
            &:hover {
              color: $mojo-blue;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
          }

          .show-advanced-button {
            color: $black;
            background-color: #c6c6c6;
            border: 0;
            border-radius: 100px;
            letter-spacing: 1px;
            font-size: 14px;
            padding: 7px 9px 4px 9px;
            text-align: center;
            margin: 0;
            transition: 0.6s;
            cursor: pointer;
            &:hover {
              color: $mojo-blue;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
            .arrow-down-small {
              color: $black;
              width: 15px;
              height: 15px;
              img,
              svg {
                color: $black;
                width: 100%;
                height: 100%;
                object-fit: contain;
                overflow: hidden;
              }
            }
          }
          .hide-advanced-button {
            color: $white;
            background-color: $mojo-blue;
            border: 0;
            border-radius: 100px;
            letter-spacing: 1px;
            font-size: 14px;
            padding: 9px 9px 4px 9px;
            text-align: center;
            margin: 0;
            transition: 0.6s;
            cursor: pointer;
            display: inline-block;
            &:hover {
              color: $black;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
            .arrow-down-small {
              width: 15px;
              height: 15px;
              transition: 0.6s;
              img,
              svg {
                width: 100%;
                height: 100%;
                object-fit: contain;
                overflow: hidden;
              }
            }
          }
          .search-clear-button {
            color: $white;
            background-color: $mojo-red;
            border-radius: 100px;
            border: 0;
            font-size: 14px;
            padding: 10px 10px 7px 10px;
            text-align: center;
            margin: 0 5px 0 5px;
            transition: 0.6s;
            cursor: pointer;
            &:hover {
              color: $black;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
          }
        }
        .mobile-buttons {
          width: 100%;
          .search-mobile-buttons {
            display: flex;
            flex-direction: row;
            align-content: center;
            justify-content: center;
            align-items: center;
            margin: 5px auto 5px;
            width: 80%;
            @include breakpoint($break-md) {
              width: 100%;
            }
            @include breakpoint($break-sm) {
              width: 100%;
            }
            @include breakpoint($break-xs) {
              width: 100%;
            }

            .search-button-name-mobile {
              color: $white;
              background-color: $mojo-blue;
              border: 0;
              border-radius: 30px;
              letter-spacing: 1px;
              font-size: 14px;
              min-width: 100px;
              padding: 10px;
              text-align: center;
              margin: 0 5px;
              transition: 0.6s;
              cursor: pointer;
              display: none;
              &:hover {
                color: $black;
              }
              @include breakpoint($break-md) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
              }
            }

            .search-button-advanced-mobile {
              color: $white;
              background-color: $black;
              border: 0;
              border-radius: 30px;
              letter-spacing: 1px;
              font-size: 14px;
              min-width: 25px;
              padding: 10px;
              text-align: center;
              margin: 0 0 0 5px;
              transition: 0.6s;
              cursor: pointer;
              display: none;
              &:hover {
                color: $mojo-blue;
              }
              @include breakpoint($break-md) {
                display: inline-block;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
              }
            }
            .search-button-advanced-mobile:disabled {
              background: #c6c6c6;
              color: #101010;
              cursor: not-allowed;
            }

            .show-advanced-button-mobile {
              color: $white;
              background-color: $black;
              border: 0;
              border-radius: 30px;
              letter-spacing: 1px;
              font-size: 14px;
              min-width: 100px;
              padding: 10px;
              text-align: center;
              margin: 0 5px;
              transition: 0.6s;
              cursor: pointer;
              display: none;
              &:hover {
                color: $mojo-blue;
              }
              @include breakpoint($break-md) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              .arrow-down-small {
                width: 15px;
                height: 15px;
                img,
                svg {
                  width: 100%;
                  height: 100%;
                  object-fit: contain;
                  overflow: hidden;
                }
              }
            }

            .hide-advanced-button-mobile {
              color: $mojo-blue;
              background-color: $black;
              border: 0;
              border-radius: 30px;
              letter-spacing: 1px;
              font-size: 14px;
              min-width: 100px;
              padding: 10px;
              text-align: center;
              margin: 0 5px;
              transition: 0.6s;
              cursor: pointer;
              display: none;
              &:hover {
                color: $white;
              }
              @include breakpoint($break-md) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              .arrow-down-small {
                width: 15px;
                height: 15px;
                -webkit-filter: invert(1); /* safari 6.0 - 9.0 */
                filter: invert(1);
                img,
                svg {
                  width: 100%;
                  height: 100%;
                  object-fit: contain;
                  overflow: hidden;
                }
              }
            }

            /* Mobile Versions */
            .show-button-mobile {
              color: $white;
              background-color: $black;
              border: 0;
              border-radius: 30px;
              letter-spacing: 1px;
              font-size: 14px;
              min-width: 70px;
              padding: 10px;
              text-align: center;
              margin-right: 5px;
              transition: 0.6s;
              cursor: pointer;
              display: none;
              &:hover {
                color: $mojo-blue;
              }
              @include breakpoint($break-md) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
            }
            .hide-button-mobile {
              color: $white;
              background-color: $black;
              border: 0;
              border-radius: 30px;
              letter-spacing: 1px;
              font-size: 14px;
              min-width: 70px;
              padding: 10px;
              text-align: center;
              margin-right: 5px;
              cursor: pointer;
              display: none;
              &:hover {
                color: $mojo-blue;
              }
              @include breakpoint($break-md) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
            }
            .search-clear-button-mobile {
              color: $white;
              background-color: $mojo-yellow;
              border-radius: 100px;
              border: 0;
              font-size: 14px;
              min-width: 70px;
              padding: 10px;
              margin: 0 5px 0 5px;
              text-align: center;
              cursor: pointer;
              display: none;
              &:hover {
                color: $black;
              }
              @include breakpoint($break-md) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-sm) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
              @include breakpoint($break-xs) {
                display: inline-block;
                margin: 0 5px 0 5px;
              }
            }
          }
        }

        /*Advanced Serach Options */
        .advanced-search {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: center;
          justify-content: center;
          align-items: center;
          margin: 10px auto;
          height: auto;
          @include breakpoint($break-lg) {
            margin: 10px auto;
            padding-left: 3px;
          }
          @include breakpoint($break-md) {
            margin: 0 auto;
          }
          @include breakpoint($break-sm) {
            flex-direction: column;
            margin: 0 auto;
          }
          @include breakpoint($break-xs) {
            flex-direction: column;
            margin: 0 auto;
          }
          /* Filter by Contract */
          input.search-advanced-contract {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            min-width: 330px;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            @include breakpoint($break-lg) {
              min-width: 256px;
            }
            @include breakpoint($break-md) {
              min-width: 200px;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
          }
          input.search-advanced-contract::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          input.search-advanced-contract:focus {
            border: 1px solid $black;
            outline: none;
          }

          /* Search by Token Name or Description */
          input.search-tokenId {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            min-width: 220px;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            @include breakpoint($break-md) {
              min-width: 200px;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1% 1% 1%;
            }
          }
          input.search-tokenId::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          input.search-tokenId:focus {
            border: 1px solid $black;
            outline: none;
          }

          /* Search by Token Name or Description */
          input.search-duplicates {
            color: $mojo-blue;
            background-color: #ffffff;
            border: 1px solid #ffffff;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 13px;
            min-width: 330px;
            padding: 11px 10px 9px;
            margin: 0 5px;
            text-align: center;
            @include breakpoint($break-md) {
              min-width: 200px;
            }
            @include breakpoint($break-sm) {
              width: 80%;
              margin: 0 1%;
            }
            @include breakpoint($break-xs) {
              width: 80%;
              margin: 0 1%;
            }
          }
          input.search-duplicates::placeholder {
            color: $mojo-blue;
            letter-spacing: 1px;
          }
          input.search-duplicates:focus {
            border: 1px solid $black;
            outline: none;
          }

          .search-button-advanced {
            color: $white;
            background-color: $black;
            border: 0;
            border-radius: 30px;
            letter-spacing: 1px;
            font-size: 14px;
            min-width: 25px;
            padding: 10px;
            text-align: center;
            margin: 0 0 0 5px;
            transition: 0.6s;
            cursor: pointer;
            display: inline-block;
            &:hover {
              color: $mojo-blue;
            }
            @include breakpoint($break-md) {
              display: none;
            }
            @include breakpoint($break-sm) {
              display: none;
            }
            @include breakpoint($break-xs) {
              display: none;
            }
          }
          .search-button-advanced:disabled {
            background: #c6c6c6;
            color: #101010;
            cursor: not-allowed;
          }
        }
      }
    }
    section#search-results {
      color: $white;
      background: $grey-90;
      position: relative;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: flex-start;
      width: 100%;
      min-height: 430px;
      padding: 30px 0 20px;

      img,
      svg {
        width: 100%;
        height: 100%;
        object-fit: contain;
        overflow: hidden;
      }

      .search-logo {
        position: fixed;
        top: 60px;
        left: 30px;
      }
      .search-results-row {
        width: 100%;
        max-width: 1279px;
        display: inline-block;
        margin: 0 auto;

        h2 {
          font-size: 34px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: center;
          text-decoration: none;
        }

        .token-list {
          width: 100%;
          max-width: $max-width;
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 5px;
          align-content: center;
          justify-content: center;
          align-items: flex-start;
          margin: 0 auto 20px;

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

          .loading-bar {
            display: flex;
            flex-direction: column;
            align-content: center;
            align-items: center;
            justify-content: center;
          }
        }

        .error-box {
          width: auto;
          display: inline-block;
          margin: 5px auto;
          display: flex;
          flex-direction: column;
          align-content: center;
          align-items: center;
          justify-content: flex-start;

          .error-status {
            width: 100%;
            color: #fff;
            width: auto;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
            text-align: left;
          }
          .error-message {
            color: #fff;
            width: 100%;
            font-size: 15px;
            font-weight: normal;
            text-align: center;
          }
        }
      }
    }
    /*
  Enter and leave animations can use different
  durations and timing functions.
*/
    .slide-fade-enter-active {
      transition: all 0.3s ease-out;
    }

    .slide-fade-leave-active {
      transition: all 0.6s cubic-bezier(1, 0.5, 0.8, 1);
    }

    .slide-fade-enter-from,
    .slide-fade-leave-to {
      transform: translateY(20px);
      opacity: 0;
    }
    section#marketplace {
      width: 100%;
      color: $black;
      background: $mojo-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: flex-start;
      padding: 0 0 40px 0;
      border-top: 1px solid $black;

      .row-header {
        width: 100%;
        max-width: $max-width;
        display: flex;
        flex-direction: row;
        align-content: flex-start;
        justify-content: center;
        align-items: center;
        margin: 50px 0 0 0;
        @include breakpoint($break-md) {
          width: 83%;
          margin: 0 auto;
        }
        @include breakpoint($break-sm) {
          width: 85%;
          margin: 0 auto;
        }
        @include breakpoint($break-xs) {
          width: 85%;
          margin: 0 auto;
        }
        h2 {
          width: 100%;
          color: $white;
          font-size: 34px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          margin: 10px 0 0 0;
          padding: 0 0 0 10px;
          .mojo-black {
            color: $black;
          }
        }
      }
      .row {
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 0;
      }

      .token-list {
        width: 100%;
        max-width: $max-width;
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 20px;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        margin: 20px auto 0;

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

      a {
        color: $black;
        font-weight: bold;
        border-bottom: 1px solid #1a1a1a;
        text-decoration: none;
      }

      p {
        line-height: 1.7;
        margin-bottom: 20px;
        text-align: center;
      }
    }
  }
}

body.dark-theme {
  section#explore-content .main section#marketplace .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  section#marketplace {
    min-height: $page-height;
    display: flex;
    align-items: center;
  }
}
</style>
