<template>
  <section id="profile">
    <div class="main">
      <section id="collection">
        <!-- Mojo Nfts -->
        <h2>Profile / Storefront</h2>
        <div v-if="!account" class="row">
          <p>Welcome to Mojo, please connect your account to access your membership NFT</p>
          <p>
            <ConnectWalletButton v-model="account" v-if="!account" btnSize="large" />
          </p>
        </div>
        <div v-if="account && !isAuthenticated" class="row">
          <p>
            You don't have an authorized Mojo NFT in your wallet to gain access.
            <br />Please check your account for an NFT with the following contract address:
            <br />
            <a :href="`https://etherscan.io/address/${mojoContractAddress}`" target="blank">
              {{ mojoContractAddress }}
            </a>
          </p>
          <p>
            <button class="mint-button" @click="$router.push('mint')">Mint NFT</button>
            <br />
            <br />
          </p>
        </div>
        <div v-if="account && isAuthenticated" class="row">
          <p>
            Thank you for authenticating with a Mojo NFT. Browse your Music NFT Collection below!
          </p>
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
const { account, isAuthenticated } = storeToRefs(store);

const mojoContractAddress = "0x6b9482bD2EEd7814EE5a88Cc93f687a3961D27Fb";

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
      const authAccount = new authNFT();
      /* Ethereum */
      let ethereumTokens = await authAccount.fetchAccountNfts(1, account.value);
      store.addEthereumTokens(...ethereumTokens);
      let ethereumTestnetTokens = await authAccount.fetchAccountNfts(5, account.value);
      store.addEthereumTokens(...ethereumTestnetTokens);
      /* Polygon */
      let polygonTokens = await authAccount.fetchAccountNfts(137, account.value);
      store.addPolygonTokens(...polygonTokens);
      let polygonTestnetTokens = await authAccount.fetchAccountNfts(80001, account.value);
      store.addPolygonTokens(...polygonTestnetTokens);
    } catch (error) {
      store.setErrorMessage("Error getting tokens:", error);
      notyf.error(`Error fetching tokens, please refresh to try again!`);
    }
  }
}

onMounted(async () => {
  await checkIfWalletIsConnected();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#profile {
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
        max-width: 1029px;
        display: inline-block;
        margin: 0 auto;
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
