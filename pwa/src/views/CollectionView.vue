<template>
  <section id="content">
    <div class="main">
      <section id="collection">
        <h2>Collection</h2>

        <div v-if="!account" class="row">
          <p>Welcome to Mojo, please connect your account to access your NFT Collection</p>
          <p>
            <ConnectWalletButton v-model="account" v-if="!account" btnSize="large" />
          </p>
        </div>

        <div v-if="account && !isAuthenticated" class="row">
          <p>
            You don't have the authorized Mojo NFT in your MetaMask Wallet to enable entry.
            <br />Please check your account for an NFT with the following contract address:
            <br />
            <a :href="`https://etherscan.io/address/${mojoContractAddress}`" target="blank">
              {{ mojoContractAddress }}
            </a>
          </p>
          <p><button class="mint-button" @click="mintNFT()">Mint NFT</button></p>
        </div>

        <div v-if="account && isAuthenticated" class="row">
          <p>Thank you for authenticating with a Mojo NFT. Browse your NFT Collection below!</p>
        </div>

        <div v-if="tokens.length > 0" class="row token-list">
          <div v-for="(token, key) in tokens" :key="key" class="token-card">
            <div class="token-image">
              <img :src="`${token.metadata.image}`" :alt="`${token.metadata.name}`" />
            </div>
            <!-- <div class="token-title">{{ token.metadata.name }}</div> -->
            <!-- <div class="token-description">{{ token.metadata.description }}</div> -->
          </div>
        </div>
      </section>
    </div>
  </section>
</template>
<script setup>
import { onMounted } from "vue";
import { Notyf } from "notyf";
/* Import our Pinia Store */
import { storeToRefs } from "pinia";
import { useStore } from "../store";
/* Import our IPFS and NftStorage Services */
import authNFT from "../services/authNFT.js";
/* Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";
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
// Init Store
const store = useStore();
// Store Values and Methods
const { account, tokens, isAuthenticated } = storeToRefs(store);
const mojoContractAddress = import.meta.env.VITE_MOJO_CORE_CONTRACT;

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

/* Fetch NFT by Account Address */
async function fetchTokens() {
  if (account.value) {
    try {
      /**
       * @dev Must add the chain id we want or all of them even
       */
      let chainId = 1;

      const authAccount = new authNFT();
      let allTokens = await authAccount.fetchAccountNfts(chainId, account.value);
      store.addTokens(allTokens);
    } catch (error) {
      store.setErrorMessage("Error getting tokens:", error);
      notyf.error(`Error fetching tokens, please refresh to try again!`);
    }
  }
}

onMounted(() => {
  checkIfWalletIsConnected();
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
      color: #212121;
      background: #fff;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 0 10px;
      overflow: scroll;

      @include breakpoint($medium) {
        padding: 0;
        flex-direction: column;
        align-content: center;
        align-items: center;
        justify-content: center;
      }

      .row {
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        padding: 0;

        @include breakpoint($medium) {
          flex-direction: column;
          align-content: center;
          justify-content: center;
          align-items: center;
        }
      }

      .token-list {
        width: 100%;
        max-width: 960px;
        display: inline-block;
        margin: 0 auto;

        .token-card {
          display: block;
          box-sizing: border-box;
          position: relative;
          width: 170px;
          height: 194px;
          background: #f4f4f4;
          border: 2px solid #f4f4f4;
          border-radius: 6px;
          overflow: hidden;
          float: center;
          margin: 0 auto 20px;
          @include breakpoint($breakpoint-sm) {
            float: left;
            margin: 0 10px 20px 10px;
          }
          @include breakpoint($breakpoint-md) {
            float: left;
            margin: 0 10px 20px 10px;
          }
          @include breakpoint($breakpoint-xl) {
            float: left;
            margin: 0 20px 20px 0;
          }

          &:hover {
            border: 2px solid #8d50f5;
          }
        }

        .token-title {
          color: #1a1a1a;
          width: 100%;
          font-size: 14px;
          font-weight: normal;
          text-transform: uppercase;
          text-align: center;
          margin: 20px 0;
        }

        .token-image {
          width: 98%;
          margin: 0 auto;
          padding: 1%;
          overflow: hidden;

          @include breakpoint($medium) {
            width: 96%;
            padding: 2%;
          }

          img,
          svg {
            width: 100%;
            height: 100%;
            object-fit: contain;
            overflow: hidden;
          }
        }
      }

      h2 {
        font-size: 1.8rem;
        text-align: center;
        margin-block-start: 0;
        margin-block-end: 0.2em;

        @include breakpoint($medium) {
          font-size: 2.25rem;
          margin-block-start: 0.3em;
          margin-block-end: 0.2em;
        }
      }

      .mint-button {
        color: #fff;
        background-color: #08d0a5;
        font-size: 18px;
        font-weight: bold;
        width: 100%;
        max-width: 360px;
        height: 55px;
        border: 0;
        padding-left: 87px;
        padding-right: 87px;
        border-radius: 10px;
        cursor: pointer;
      }

      .mint-button:disabled {
        background: #c6c6c6;
        color: #101010;
        cursor: not-allowed;
      }

      a {
        color: #1a1a1a;
        font-weight: bold;
        border-bottom: 1px solid #1a1a1a;
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
        text-align: center;
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
