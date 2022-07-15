<script setup>
import { ref } from 'vue';
import { ethers } from 'ethers';
import contractAbi from '../../../artifacts/contracts/MojoCore.sol/MojoCore.json';
console.log('contractAbi: ', contractAbi);

const name = ref('');
const description = ref('');
const externalUrl = ref('');
const imageUrl = ref('');
const backgroundColor = ref('ffffff');
const attributes = ref([]);

async function mintNFT() {
  if (!name.value) {
    return;
  }

  if (name.value.length < 3) {
    alert('NFT name must be longer then 3');
    return;
  }

  const price = name.value.length === 3 ? '0.05' : name.value.length === 4 ? '0.03' : '0.01';
  console.log('Minting NFT name', name.value, 'with price', price);

  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();

      /* Dev Note: Reset this once Contracts deployed */
      const contract = new ethers.Contract(process.env.MOJO_CORE_CONTRACT, contractAbi.abi, signer);
      console.log('Talk to the wallet and pay gas');

      let nftTxn = await contract.makeAnEpicNFT();
      console.log('Mining...please wait.');
      const receipt = await nftTxn.wait();
      console.log(nftTxn);
      if (receipt.status === 1) {
        console.log(`NFT Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
      }

      name.value = '';
      description.value = '';
    } else {
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    console.log('error', error);
  }
}
</script>

<template>
  <div className="form-container">
    <div className="input-row">
      <input type="text" placeholder="name" v-model="name" />
    </div>
    <div className="input-row">
      <input type="text" placeholder="description" v-model="description" />
    </div>
    <div className="input-row">
      <input type="text" placeholder="externalUrl" v-model="externalUrl" />
    </div>
    <div className="input-row">
      <input type="text" placeholder="imageUrl" v-model="imageUrl" />
    </div>
    <div className="input-row">
      <input type="text" placeholder="backgroundColor" v-model="backgroundColor" />
    </div>
    <div className="input-row">
      <input type="text" placeholder="backgroundColor" v-model="backgroundColor" />
    </div>
    <p className="tld">{{ attributes }}</p>

    <div className="button-container">
      <button className="mint-button" @click="mintNFT">Mint NFT</button>
    </div>
  </div>
</template>
<style lang="scss" scoped>
.form-container {
  display: flex;
  width: 100%;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

input {
  border: 0;
  border-radius: 12px;
  background-color: #ffffff;
  color: #1a1a1a;
  letter-spacing: 1px;
  font-size: 26px;
  width: 400px;
  margin-bottom: 10px;
  padding: 10px 20px;
  text-align: center;
}

input::placeholder {
  color: gray;
  letter-spacing: 2px;
}

input:focus {
  outline: none;
}

.input-row {
  position: relative;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.tld {
  position: absolute;
  font-size: 20px;
  font-weight: bold;
  color: white;
  /* left: -70px; */
  right: 22px;
  margin: 0;
  padding: 0;
  margin-bottom: 13px;
}

.mint-button {
  background: -webkit-linear-gradient(left, #a200d6, #ff6fdf);
  font-size: 18px;
  background-size: 200% 200%;
  animation: gradient-animation 4s ease infinite;
  margin: 20px 10px;
  border-radius: 20px;
  padding: 0px 2rem;
}

.mint-button:disabled {
  background: #550072;
  color: rgb(209, 209, 209);
  cursor: not-allowed;
}

.mint-list {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  margin-top: 20px;
}

.mint-item {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  padding: 10px 15px;
  border-radius: 5px;
  margin: 10px 15px;
  font-size: 18px;
  background-color: #c4b7fa;
  color: black;
  min-width: 150px;
  max-width: fit-content;
  box-shadow: 0px 0px 10px 3px rgba(255, 255, 255, 0.2);
}

/* Different background-colour for every nth mint-item */
.mint-item:nth-child(2n) {
  background-color: lightblue;
}

.mint-item:nth-child(3n) {
  background-color: lightpink;
}

.mint-item:nth-child(5n) {
  background-color: lightgreen;
}
</style>
