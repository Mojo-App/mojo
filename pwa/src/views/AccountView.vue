<template>
  <section id="account">
    <div class="left">
      <div v-if="!account && !isAuthenticated" class="account-connect-card">
        <h2>Account</h2>
        <p>Welcome to Mojo, please connect your Metamask to access your account.</p>
        <p>
          <ConnectWalletButton v-model="account" btnSize="small" />
        </p>
      </div>
      <div v-if="account && !isAuthenticated" class="account-connect-card">
        <h2>Profile</h2>
        <p>Welcome to Mojo, you can now update your profile and storefront.</p>
        <p>
          <!-- <ConnectWalletButton v-model="account" btnSize="small" /> -->
        </p>
      </div>
      <div v-if="account && isAuthenticated" class="account-connect-card">
        <h2>Authenticated</h2>
        <p>Welcome to Mojo, your account is authenticated.</p>
        <p>
          <!-- <ConnectWalletButton v-model="account" btnSize="small" /> -->
        </p>
      </div>
    </div>
    <div class="right">
      <div class="account-card">
        <div v-if="account && !isAuthenticated" class="row">
          <p>
            You don't have an authorized Mojo Creators NFT in your wallet?
            <br />Please check your account for an NFT with the following contract address:
            <br />
            <a :href="`https://etherscan.io/address/${mojoContractAddress}`" target="blank">
              {{ mojoContractAddress }}
            </a>
          </p>
          <p>
            <button class="home-button" @click="$router.push({ name: 'home' })">home</button>
          </p>
        </div>
        <div v-if="account && isAuthenticated" class="row">
          <p>
            Thank you for authenticating with a Mojo NFT. Please make sure your profile is completed
            for your storefront.
          </p>
        </div>
      </div>
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
/* Init Store and Refs */
const store = useStore();
const { account, isAuthenticated } = storeToRefs(store);
/* Mojo Contract Address */
const mojoContractAddress = "0x50878dC8674A3738d3C1fCA76F9DB308Ed2EFE4D";
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
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: "smooth",
  });
  await checkIfWalletIsConnected();
  await fetchTokens();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#account {
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

  .bg-shape {
    background: #fff;
    background-image: url("./BlackCorner.png");
    background-repeat: no-repeat;
    background-position: center right;
    background-size: auto;
  }

  .left {
    width: 30%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-content: center;
    justify-content: flex-start;
    align-items: center;
    padding: 40px;

    @include breakpoint($break-ssm) {
      width: 100%;
      padding: 20px;
    }

    .account-connect-card {
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      align-items: center;
      align-content: center;
      background: #fff;
      border: 4px solid var(--gradient-100);
      box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
      border-radius: 10px;
      margin: 0 auto 15px;
      padding: 30px 40px 20px;
      z-index: 999;

      h2 {
        width: 100%;
        color: $black;
        font-size: 34px;
        font-style: normal;
        font-weight: 700;
        line-height: 42px;
        text-align: center;
        margin: 0;
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
  .right {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-content: center;
    justify-content: flex-start;
    align-items: center;
    padding: 40px 20px 40px 0;

    @include breakpoint($break-ssm) {
      width: 100%;
      padding: 20px;
    }

    .account-card {
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      align-items: center;
      align-content: center;
      background: #fff;
      border: 4px solid var(--gradient-100);
      box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
      border-radius: 10px;
      margin: 0 auto 15px;
      padding: 30px 40px 20px;
      z-index: 999;

      .row-header {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: flex-start;
        justify-content: center;
        align-items: center;
        margin: 50px 0 0 0;

        h2 {
          font-size: 1.8rem;
          text-align: center;
          margin-block-start: 0;
          margin-block-end: 0.2em;

          @include breakpoint($break-ssm) {
            font-size: 2.25rem;
            margin-block-start: 0.3em;
            margin-block-end: 0.2em;
          }
        }
        h2 {
          width: 100%;
          color: $black;
          font-size: 34px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: left;
          margin: 0;
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

      .row {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        padding: 0;
      }

      .home-button {
        color: #fff;
        background-color: $mojo-green;
        font-size: 18px;
        font-weight: bold;
        max-width: 360px;
        height: 55px;
        border: 0;
        border-radius: 30px;
        padding-left: 57px;
        padding-right: 57px;
        transition: 0.4s;
        cursor: pointer;

        &:hover {
          color: $black;
        }
      }
    }
  }
}

body.dark-theme {
  section#account .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .account {
    min-height: $page-height;
    display: flex;
    align-items: center;
  }
}
</style>
