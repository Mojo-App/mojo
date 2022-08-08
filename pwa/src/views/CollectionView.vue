<template>
  <section id="content">
    <div class="main">
      <section id="collection">
        <h2>Collection</h2>
        <div class="row">
          <div v-if="!account">
            <p>Welcome to Mojo, please connect your account to access your NFT Collection</p>
          </div>

          <div v-if="account && !isAuthenticated">
            <p>
              You don't have the authorized Mojo NFT in your MetaMask Wallet to enable entry.
              <br />Please check your account for an NFT with the following contract address:
              <br />
              <a :href="`https://etherscan.io/address/${mojoContractAddress}`" target="blank">
                {{ mojoContractAddress }}
              </a>
            </p>
          </div>
          <div v-if="account && isAuthenticated">
            <p>Thank you for authenticating with a Mojo NFT. Browse your NFT Collection below!</p>
          </div>
          <p>Account: {{ account }}</p>
          <p>mojoContractAddress: {{ mojoContractAddress }}</p>
          <p>isAuthenticated: {{ isAuthenticated }}</p>
          <p>walletConnectionAttempted: {{ walletConnectionAttempted }}</p>
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
const { account, isAuthenticated, walletConnectionAttempted } = storeToRefs(store);
const mojoContractAddress = import.meta.env.VITE_MOJO_CORE_CONTRACT;
console.log(mojoContractAddress);
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

/* Fetch new NFT audio/media by Category or Name */
async function fetchData() {
  // try {
  //   await store.searchNfts(categorySelectedId.value, "");
  //   /* Console log with some style */
  //   const stylesTracks = ["color: black", "background: yellow"].join(";");
  //   console.log("%c📻 NFT Audio/Media fetched : %s 📻", stylesTracks, JSON.stringify(trackList));
  // } catch (error) {
  //   console.log(error);
  // }
}

onMounted(() => {
  fetchData();
  checkIfWalletIsConnected();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#content {
  position: relative;
  height: 100%;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0 0 10px 0;
    overflow: hidden;

    @include breakpoint($medium) {
      height: 99%;
    }

    section#collection {
      height: 100%;
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

        @include breakpoint($medium) {
          flex-direction: column;
          align-content: center;
          justify-content: center;
          align-items: center;
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
