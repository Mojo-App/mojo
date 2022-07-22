<script setup>
defineProps({
  currentAccount: String,
  btnSize: {
    type: String,
    required: false,
  },
});
/* Define Emits */
const emit = defineEmits(["update:modelValue"]);
/* Connect Wallet method */
async function connectWallet() {
  const { ethereum } = window;
  try {
    if (!ethereum) {
      alert("Please connect 🦊 Metamask to continue!");
      return;
    }
    const accounts = await ethereum.request({
      method: "eth_requestAccounts",
    });
    emit("update:modelValue", accounts[0]);
  } catch (error) {
    console.log("Error", error);
  }
}
</script>
<template>
  <div class="connect-wallet-container">
    <button v-if="btnSize === 'large'" @click="connectWallet" class="connect-wallet-button">
      🎧 Connect Wallet
    </button>
    <button v-if="btnSize === 'small'" @click="connectWallet" class="connect-wallet-small-button">
      🎧 Connect
    </button>
  </div>
</template>
