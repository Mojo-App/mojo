<template>
  <div class="connect-wallet-container">
    <!-- Metamask Not Connected -->
    <button
      v-if="!account"
      @click="connectWallet()"
      :class="btnSize === 'large' ? 'connect-wallet-button' : 'connect-wallet-small-button'"
    >
      connect
    </button>
    <!-- Metamask Connected -->
    <button
      v-if="account"
      @click="$router.push('account')"
      :class="btnSize === 'large' ? 'profile-wallet-button' : 'profile-wallet-small-button'"
    >
      account
    </button>
  </div>
</template>
<script setup>
/* Import our Pinia Store & Refs */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Import our IPFS and NftStorage Services */
import authNFT from "../services/authNFT.js";

/* Set our Props */
defineProps({
  currentAccount: String,
  btnSize: {
    type: String,
    required: false,
  },
});

/* Define Emits */
const emit = defineEmits(["update:modelValue"]);

/* Init Store & Refs */
const store = useStore();
const { account } = storeToRefs(store);

/* Connect Wallet method */
async function connectWallet() {
  store.setLoading(true);
  try {
    /*
     * First make sure we have access to window.ethereum
     */
    const { ethereum } = window;
    if (!ethereum) {
      alert("Please connect 🦊 Metamask to continue!");
      return;
    }
    /* Get our Current Account */
    const [accountAddress] = await ethereum.request({
      method: "eth_requestAccounts",
    });
    if (accountAddress) {
      /* Update our Current Account in the Store */
      store.updateAccount(accountAddress);
      console.log("Account Address", accountAddress);

      /* Authenticate user */
      const authAccount = new authNFT();
      /* Mojo Music NFT holder */
      const authed = await authAccount.authAccountAddress(accountAddress);
      if (authed) {
        store.setIsAuthenticated(authed);
      }
      /* or Tableland Rig NFT holders */
      const rigRider = await authAccount.authTablelandContractAddress(accountAddress);
      if (rigRider) {
        store.setIsAuthenticated(rigRider);
      }
      /* Emit our account back to parent */
      emit("update:modelValue", accountAddress);
      store.setLoading(false);
    }
    store.setLoading(false);
  } catch (error) {
    console.log("Error", error);
    store.setLoading(false);
  }
}
</script>

<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

.connect-wallet-button {
  color: $black;
  background-color: $white;
  font-size: 18px;
  font-weight: bold;
  width: auto;
  height: 55px;
  border: 2px solid $mojo-green;
  border-radius: 30px;
  padding-left: 60px;
  padding-right: 60px;
  transition: 0.4s;
  cursor: pointer;

  &:hover {
    color: $mojo-blue;
  }
}

.connect-wallet-small-button {
  color: $black;
  background-color: $white;
  font-size: 14px;
  font-weight: bold;
  width: auto;
  height: 35px;
  border: 2px solid $mojo-green;
  border-radius: 30px;
  padding-left: 20px;
  padding-right: 20px;
  margin-right: 10px;
  transition: 0.4s;
  cursor: pointer;

  &:hover {
    color: $mojo-blue;
  }
}

.profile-wallet-button {
  color: $black;
  background-color: $white;
  font-size: 18px;
  font-weight: bold;
  width: auto;
  height: 55px;
  border: 2px solid $mojo-blue;
  border-radius: 30px;
  padding-left: 60px;
  padding-right: 60px;
  transition: 0.4s;
  cursor: pointer;

  &:hover {
    color: $mojo-light-blue;
  }
}

.profile-wallet-small-button {
  color: $black;
  background-color: $white;
  font-size: 14px;
  font-weight: bold;
  width: auto;
  height: 35px;
  border: 2px solid $mojo-blue;
  border-radius: 30px;
  padding-left: 20px;
  padding-right: 20px;
  margin-right: 10px;
  transition: 0.4s;
  cursor: pointer;

  &:hover {
    color: $mojo-light-blue;
  }
}

body.dark-theme {
  .connect-wallet-button {
    color: $mojo-green;
    background-color: $white;
    font-size: 18px;
    font-weight: bold;
    width: auto;
    height: 55px;
    border: 2px solid $mojo-green;
    border-radius: 30px;
    padding-left: 60px;
    padding-right: 60px;
    transition: 0.4s;
    cursor: pointer;

    &:hover {
      color: $mojo-blue;
    }
  }

  .connect-wallet-small-button {
    color: $mojo-green;
    background-color: $black;
    font-size: 14px;
    font-weight: bold;
    width: auto;
    height: 35px;
    border: 2px solid $mojo-green;
    border-radius: 30px;
    padding-left: 20px;
    padding-right: 20px;
    margin-right: 10px;
    transition: 0.4s;
    cursor: pointer;

    &:hover {
      color: $mojo-blue;
    }
  }

  .profile-wallet-button {
    color: $mojo-blue;
    background-color: $black;
    font-size: 18px;
    font-weight: bold;
    width: auto;
    height: 55px;
    border: 2px solid $mojo-blue;
    border-radius: 30px;
    padding-left: 60px;
    padding-right: 60px;
    transition: 0.4s;
    cursor: pointer;

    &:hover {
      color: $mojo-green;
    }
  }

  .profile-wallet-small-button {
    color: $mojo-blue;
    background-color: $black;
    font-size: 14px;
    font-weight: bold;
    width: auto;
    height: 35px;
    border: 2px solid $mojo-blue;
    border-radius: 30px;
    padding-left: 20px;
    padding-right: 20px;
    margin-right: 10px;
    transition: 0.4s;
    cursor: pointer;

    &:hover {
      color: $mojo-green;
    }
  }
}
</style>
