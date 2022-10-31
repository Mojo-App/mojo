<template>
  <section id="account">
    <div class="left">
      <!-- No Metamask Connected  -->
      <div v-if="!account && !isAuthenticated" class="account-connect-card">
        <h2>Account</h2>
        <p>Welcome to Mojo Music, let's get you rockin' ready!</p>
        <p>Please connect your Metamask wallet to get started creating an account!</p>
        <p>
          <ConnectWalletButton v-model="account" btnSize="small" />
        </p>
      </div>
      <!-- Step 1: Metamask connected but must Mint mcNFT -->
      <div v-if="account && !isAuthenticated" class="account-connect-card">
        <h2>Mint Maker</h2>
        <p>You don't have an authorized NFT in your wallet? 🐝🔫</p>
        <p>Let's keep the party going and mint a Mojo Creator NFT</p>
        <p>
          Please check your account for an NFT with the following contract address:
          <br />
          <a
            :href="`https://etherscan.io/address/${mojoCreatorsContractAddress}`"
            target="blank"
            class="contract-address"
          >
            {{ mojoCreatorsContractAddress }}
          </a>
        </p>
        <p>
          <button class="home-button" @click="$router.push({ name: 'home' })">home</button>
        </p>
      </div>
      <!-- Step 2: Metamask Connected and Mojo NFT Authenticated, can update Profile -->
      <div v-if="account && isAuthenticated" class="account-connect-card">
        <h2>Account</h2>
        <p>
          Thank you for authenticating with a Mojo NFT. Please make sure your profile is completed
          for your storefront.
        </p>
        <p>
          <button class="home-button" @click="$router.push({ name: 'home' })">home</button>
        </p>
      </div>
    </div>
    <!-- Right Hand Side -->
    <div class="right">
      <div class="account-card">
        <!-- Step 1: Mint a Mojo Creators Membership NFT -->
        <div v-if="account && !isAuthenticated" class="form-container">
          <h2>Mint Creator NFT</h2>
          <div
            class="panel-upload--dropzone"
            :class="{ active: isDragged }"
            @dragenter="onDragEnter"
            @dragleave="onDragLeave"
            @drop.prevent="onDropHandler"
            @dragover.prevent
          >
            <input type="file" multiple ref="fileRef" @change="onFileChangedHandler" />
            <div class="dropzone-box" @click="openSelectFile">
              <i-mdi-timer-sand v-if="isUploading" class="icon-color" />
              <i-mdi-upload v-else class="icon-color" />
              <span>Drop files here for upload to IPFS</span>
              <div class="dropzone-is-loading" :class="{ active: isUploading }">
                <div class="dropzone-loading--bar"></div>
              </div>
              <span v-show="fileCount > 0"
                >{{ fileCount - finished }} of {{ fileCount }} files uploaded</span
              >
              <div class="dropzone-details">
                <div class="dropzone-detail">{{ result.count }} files</div>
                <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
              </div>
            </div>
          </div>
          <div v-show="imageUrl" class="file-view-link">
            <a :href="imageUrl" title="Open in new tab" target="_blank">View</a>
          </div>
          <div class="input-row">
            <label>Name</label>
            <input type="text" v-model="name" />
          </div>
          <div class="input-row">
            <label>Description</label>
            <textarea v-model="description" rows="5" cols="50"></textarea>
          </div>
          <div class="input-row">
            <label>Account Address</label>
            <input type="text" v-model="accountAddress" />
          </div>
          <div class="button-container">
            <button
              class="mint-button"
              :disabled="!name || !description || !accountAddress || !imageUrl"
              @click="mintNFT()"
            >
              {{ minting ? "minting" : "mint" }}
            </button>
            <!-- <button class="restart-button" @click="cancelMint()">cancel</button> -->
          </div>
        </div>

        <!-- Step 2: Show Account Details -->
        <div v-if="tokenId && isAuthenticated" class="nft-modal-card">
          <div class="nft-banner-image">
            <img
              v-if="banner_img"
              :src="`${getUrlProtocol(banner_img)}`"
              :alt="`${name ? name : ''}`"
            />
            <button
              :class="banner_img ? 'nft-banner-image-edit-button' : 'nft-banner-image-add-button'"
              @click="updateBannerImg(banner_img)"
            >
              {{ banner_img ? "edit" : "add" }}
            </button>
          </div>
          <div class="nft-modal-card">
            <div class="row">
              <div class="column">
                <div v-if="getUrlProtocol(imageUrl) === 'mp4'" class="nft-modal-video">
                  <video height="240" controls>
                    <source :src="imageUrl" type="video/mp4" />
                    Your browser does not support the video tag.
                  </video>
                  <button
                    :class="imageUrl ? 'nft-modal-image-edit-button' : 'nft-modal-image-add-button'"
                    @click="updateImage(imageUrl)"
                  >
                    {{ imageUrl ? "edit" : "add" }}
                  </button>
                </div>
                <div v-if="getUrlProtocol(imageUrl) === 'mp3'" class="nft-modal-video">
                  <audio ref="player" height="240">
                    <source :src="imageUrl" type="audio/mpeg" />
                  </audio>
                  <video height="240" controls>
                    <source :src="getUrlProtocol(imageUrl)" type="video/mp3" />
                    Your browser does not support the video tag.
                  </video>
                  <button
                    :class="imageUrl ? 'nft-modal-image-edit-button' : 'nft-modal-image-add-button'"
                    @click="updateImage(imageUrl)"
                  >
                    {{ imageUrl ? "edit" : "add" }}
                  </button>
                </div>
                <div v-else-if="imageUrl" class="nft-modal-image">
                  <img :src="`${getUrlProtocol(imageUrl)}`" :alt="`${name}`" />
                  <button
                    :class="imageUrl ? 'nft-modal-image-edit-button' : 'nft-modal-image-add-button'"
                    @click="updateImage(imageUrl)"
                  >
                    {{ imageUrl ? "edit" : "add" }}
                  </button>
                </div>
              </div>
            </div>
            <div class="row">
              <div class="nft-profile-image">
                <img
                  v-if="profile_img"
                  :src="`${getUrlProtocol(profile_img)}`"
                  :alt="`${name ? name : ''}`"
                />
                <button
                  :class="
                    profile_img ? 'nft-profile-image-edit-button' : 'nft-profile-image-add-button'
                  "
                  @click="updateProfileImg(profile_img)"
                >
                  {{ profile_img ? "edit" : "add" }}
                </button>
              </div>
              <div class="column">
                <div class="nft-modal-title">
                  <label>Name</label>
                  <input type="text" name="name" v-model="name" @change="updateName(name)" />
                </div>
                <div class="nft-modal-address">
                  <label>Account Address</label>
                  <input
                    type="text"
                    name="address"
                    v-model="accountAddress"
                    @change="updateAddress(accountAddress)"
                  />
                </div>
                <div class="nft-modal-website">
                  <label>Website</label>
                  <input
                    type="text"
                    name="website"
                    v-model="website"
                    @change="updateWebsite(website)"
                  />
                </div>
                <div class="nft-modal-slogan">
                  <label>Slogan</label>
                  <input
                    type="text"
                    name="slogan"
                    v-model="slogan"
                    @change="updateSlogan(slogan)"
                  />
                </div>
                <div class="nft-modal-description">
                  <label>Description</label>
                  <textarea
                    v-model="description"
                    rows="5"
                    cols="50"
                    @change="updateDescription(description)"
                  ></textarea>
                </div>
                <!-- Add Traits Form -->
                <div class="nft-modal-add-attribute">
                  <div class="nft-add-attribute">
                    <div class="nft-attribute-icon">
                      <label>Trait Icon</label>
                      <input
                        type="text"
                        name="traitIcon"
                        v-model="traitIcon"
                        @change="updateTraitIcon(traitIcon)"
                      />
                    </div>
                    <div class="nft-attribute-display-type">
                      <!-- TODO This need to be a select with options from opensea -->
                      <label>Trait Display Type</label>
                      <input
                        type="text"
                        name="traitDisplayType"
                        v-model="traitDisplayType"
                        @change="updateTraitDisplayType(traitDisplayType)"
                      />
                      <!-- TODO This need to be a select with options from opensea -->
                    </div>
                    <div class="nft-attribute-trait-type">
                      <label>Trait Type</label>
                      <input
                        type="text"
                        name="traitType"
                        v-model="traitType"
                        @change="updateTraitType(traitType)"
                      />
                    </div>
                    <div class="nft-attribute-value">
                      <label>Trait Value</label>
                      <input
                        type="text"
                        name="traitValue"
                        v-model="traitValue"
                        @change="updateTraitValue(traitValue)"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <!-- NFT Metadata Attributes -->
            <div v-if="attributes.length > 0" class="nft-modal-edit-attributes">
              <template v-for="attr in attributes" :key="attr.trait_id">
                <div v-if="attr.trait_value" class="nft-attribute-cards">
                  <div class="nft-attribute-card">
                    <div class="nft-attribute-card-trait">
                      #{{ attr.trait_id }} {{ attr.icon }} {{ attr.display_type }} /
                      {{ attr.trait_type }} :
                      {{ attr.trait_value }}
                      <button
                        v-show="attr.trait_id"
                        class="edit-button"
                        @click="editTrait(attr.trait_id)"
                      >
                        {{ showTrait.value === attr.trait_id ? "done" : "edit" }}
                      </button>
                    </div>
                  </div>
                </div>
              </template>
              <template v-for="attr in attributes" :key="attr.trait_id">
                <div v-if="showTrait === attr.trait_id && attr.trait_value" class="nft-attribute">
                  Trait #{{ attr.trait_id }}
                  <div class="nft-attribute-icon">
                    <input
                      type="text"
                      name="traitIcon"
                      v-model.lazy="attr.icon"
                      @change="updateTraitIcon(attr)"
                    />
                  </div>
                  <div class="nft-attribute-display-type">
                    <!-- TODO This need to be a select with options from opensea -->
                    <input
                      type="text"
                      name="traitDisplayType"
                      v-model.lazy="attr.display_type"
                      @change="updateTraitDisplayType(attr)"
                    />
                    <!-- TODO This need to be a select with options from opensea -->
                  </div>
                  <div class="nft-attribute-trait-type">
                    <input
                      type="text"
                      name="traitType"
                      v-model.lazy="attr.trait_type"
                      @change="updateTraitType(attr)"
                    />
                  </div>
                  <div class="nft-attribute-value">
                    <input
                      type="text"
                      name="traitValue"
                      v-model.lazy="attr.trait_value"
                      @change="updateTraitValue(attr)"
                    />
                  </div>
                </div>
              </template>
            </div>
            <!-- Control Panel -->
            <div class="nft-modal-approve">
              <div v-show="tokenId" class="button-container">
                <button class="add-button" @click="AddNewAttribute()">add new attribute</button>
              </div>
              <button
                v-show="!tokenId"
                :class="!approvedMint ? 'approve-button' : 'approved-button'"
                @click="ConfirmApprovedMint(true)"
              >
                Update
              </button>
            </div>
            <!-- END Control Panel -->
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
<script setup>
import { ref, computed, onMounted } from "vue";
import { ethers, BigNumber } from "ethers";
import { Notyf } from "notyf";
import moment from "moment";

/* Import our Pinia Store */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Import our IPFS and NftStorage Services */
import { uploadBlob } from "../services/ipfs.js";
import { fileSize, generateLink } from "../services/helpers";
import JSConfetti from "js-confetti";

/* Import our IPFS and NftStorage Services */
import authNFT from "../services/authNFT.js";

/* Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";

/* Import Smart Contract ABI and Mojo Contract Address */
import contractAbi from "../../../artifacts/contracts/mojo_mc_ERC721.sol/MCNFT.json";
const mojoCreatorsContractAddress = "0x22Dbbb789aE924dCA4C2366Fc4d34f269e2fC3B3";

/* Console log with some style */
const stylesContract = ["color: black", "background: #e9429b"].join(";");
console.log("%c🎧 Mojo Contract Address %s ", stylesContract, mojoCreatorsContractAddress);
const stylesAbi = ["color: black", "background: cyan"].join(";");
console.log("%c🧭 Contract ABI Source %s 🧭", stylesAbi, contractAbi.sourceName);

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
const { minting, account, isAuthenticated } = storeToRefs(store);

/* File Uploader Refs */
const fileRef = ref(null);
const isDragged = ref(false);
const finished = ref(0);
const isUploading = ref(false);
const cid = ref("");

/* Mojo Creators NFT Form Metadata fields */
const tokenId = ref("");
const name = ref("");
const description = ref("");
const imageUrl = ref("");
const slogan = ref("");
const accountAddress = ref("");
const website = ref("");
const profile_img = ref("");
const banner_img = ref("");
const audioVideoType = ref("");
const size = ref("");
const createdAt = ref("");
const updatedAt = ref("");

/* Updating Traits Form
 * Traits start at 0 on mint, the date of mint is the first trait added
 */
/* NFT Form Metadata Attributes */
const attributes = ref([]);
const showTrait = ref(0);
const traitTableId = ref(null);
const traitTokenId = ref(null);
const traitId = ref(null);
const traitIcon = ref("");
const traitDisplayType = ref("");
const traitType = ref("");
const traitValue = ref("");
const traitCreatedAt = ref("");
const traitUpdatedAt = ref("");

const approvedMint = ref(false);

const jsConfettiSuccess = (emojis) => {
  const jsConfetti = new JSConfetti();
  jsConfetti.addConfetti({
    emojis: emojis,
    emojiSize: 100,
    confettiRadius: 6,
    // confettiNumber: 100,
  });
};

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
      console.log("Error: No ethereum window object");
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

/* Authenticate NFT Holder method */
async function authenticateNFT() {
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
      const authed = await authAccount.authMojoCreatorAccountAddress(accountAddress);
      console.log("Authed Mojo NFT Holder", authed);

      if (authed) {
        store.setIsAuthenticated(authed);
      }
      /* or Tableland Rig NFT holders */
      const rigRider = await authAccount.authTablelandContractAddress(accountAddress);
      console.log("Authed Tableland Rig Holder", rigRider);
      if (rigRider) {
        store.setIsRigHolder(rigRider);
      }
    }
  } catch (error) {
    console.log("Error", error);
  }
}

/**
 * Mint NFT
 */
const mintNFT = async () => {
  /**
   * Some very basic form validation, these are loaded after IPFS upload
   * but users can edit so we still need some validation in UI
   */
  if (!name.value) {
    notyf.error(`Please enter a name to continue!`);
    return;
  }
  if (name.value.length < 3) {
    notyf.error(`Name must be longer then 3 characters!`);
    return;
  }
  if (!imageUrl.value) {
    notyf.error(`Please upload an image to continue!`);
    return;
  }
  if (imageUrl.value.length < 10) {
    notyf.error(`Please upload a valid image to continue!`);
    return;
  }
  if (!accountAddress.value) {
    notyf.error(`Please enter an Account Address to continue!`);
    return;
  }
  if (accountAddress.value.length < 20) {
    notyf.error(`AccountAddress must be longer then 20 characters!`);
    return;
  }
  if (!description.value) {
    notyf.error(`Please enter a description to continue!`);
    return;
  }
  if (description.value.length < 10) {
    notyf.error(`Description must be longer then 10 characters!`);
    return;
  }

  /* Init loading indicator */
  const loadingIndicator = notyf.open({
    type: "loading",
    message: "⏳ Please wait while we get our mojo on, minting in progress...",
  });

  /* Show minting loader */
  store.setMinting(true);

  /**
   * Mint our NFT with additional metadata on NFT.Storage
   */
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);

      /* Console log with some style */
      const styles = ["color: black", "background: #2bb5f0"].join(";");
      console.log("%c🎧 Mojo Creators Contract Address:  %s ", styles, mojoCreatorsContractAddress);

      /**
       *  Receive Emitted Event from Contract
       *  @dev See NewNftMinted emitted from our smart contract safeMint function
       */
      contract.on("NewNftMinted", (receiver, timestamp, newTokenId) => {
        console.log("Receiver :", receiver);

        createdAt.value = moment.unix(timestamp).toString();
        console.log("Created At :", createdAt.value);

        tokenId.value = newTokenId.toNumber();
        console.log("TokenId :", tokenId.value);

        /* Stop minting loader */
        store.setMinting(false);
      });

      console.log("name :", name.value);
      console.log("description :", description.value);
      console.log("imageUrl :", imageUrl.value);
      console.log("accountAddress :", accountAddress.value);

      const mintDate = new Date();
      const mintDateTimestamp = mintDate.getTime();
      const mintDateString = mintDateTimestamp.toString();
      console.log("Mint Date String :", mintDateString);

      /* Mint our NFT */
      let nftTxn = await contract.safeMint(
        signer.getAddress(),
        name.value.toString(),
        description.value.toString(),
        imageUrl.value.toString(),
        accountAddress.value.toString(),
        "https://cloudflare-ipfs.com/ipfs/QmRrfbnwUtz6THu63wNHtCPnHRc7htxDsjTJfhStGFtnqR",
        "date",
        "Created",
        mintDateString
      );

      /* Console log with some style */
      const stylesMining = ["color: black", "background: yellow"].join(";");
      console.log("%c⛏ Mining...please wait!  %s ", stylesMining, nftTxn.hash);

      // The OpenZeppelin base ERC721 contract emits a Transfer event
      // when a token is issued. tx.wait() will wait until a block containing
      // our transaction has been mined and confirmed. The transaction receipt
      // contains events emitted while processing the transaction.
      const receipt = await nftTxn.wait();

      /* Console log with some style */
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c💎 We just added another music maker! %s ", stylesReceipt, nftTxn.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        /* Console log with some style */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT Minted on Polygon Mumbai, see transaction: https://mumbai.polygonscan.com/tx/${nftTxn.hash} %s`,
          stylesPolygon,
          nftTxn.hash
        );
        /* Remove loading indicator and show success notification */
        notyf.dismiss(loadingIndicator);
        notyf.open({
          type: "success",
          message: `🧬 NFT has been minted successfully, see transaction: https://mumbai.polygonscan.com/tx/${nftTxn.hash}`,
        });
      }
      /* Stop minting loader */
      store.setMinting(false);
      store.setIsAuthenticated(true);
      /* Celebrate good times, comon!!! */
      jsConfettiSuccess(["🚀", "🔥", "🏴‍☠️", "🌈", "⚡️", "💥", "✨", "💫", "🌸", "🦄"]);
      return;
    } else {
      /* Stop minting loader */
      store.setMinting(false);
      notyf.dismiss(loadingIndicator);
      notyf.error("Ethereum object doesn't exist! Oh dear...welcome to web3!");
    }
  } catch (error) {
    /* Stop minting loader */
    store.setMinting(false);
    notyf.dismiss(loadingIndicator);
    console.log("error", error);
  }
};

/**
 * Update image of Mojo Creators NFT
 */
const updateImage = async (image) => {
  console.log("Image Url: ", image);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  if (!image) {
    console.log(`Please select a new image to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on("imageUpdated", (receiver, timestamp, metadata_table_id, image, token_id) => {
        console.log("Receiver :", receiver);

        updatedAt.value = moment.unix(timestamp).toString();
        console.log("Updated At :", traitUpdatedAt.value);

        const metadataTableId = metadata_table_id.toNumber();
        console.log("Metadata Table Id :", metadataTableId);

        const imageUrl = image.toString();
        console.log("image URL :", imageUrl);

        const tokenId = token_id.toNumber();
        console.log("Token Id :", tokenId);

        /* Stop loading */
        store.setLoading(false);
      });

      let tx = await contract.update_image(
        BigNumber.from(tokenId.value),
        imageUrl.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the image url %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update name of Mojo Creators NFT
 */
const updateName = async (name) => {
  console.log("name", name);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!name) {
    console.log(`Please enter a name to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on("nameUpdated", (receiver, timestamp, metadata_table_id, name, token_id) => {
        console.log("Receiver :", receiver);

        updatedAt.value = moment.unix(timestamp).toString();
        console.log("Updated At :", traitUpdatedAt.value);

        const metadataTableId = metadata_table_id.toNumber();
        console.log("Metadata Table Id :", metadataTableId);

        const tokenId = token_id.toNumber();
        console.log("Token Id :", tokenId);

        const nameNew = name.toString();
        console.log("Name :", nameNew);

        /* Stop loading */
        store.setLoading(false);
      });

      let tx = await contract.update_name(BigNumber.from(tokenId.value), name.value.toString());

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the image url %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update description of Mojo Creators NFT
 */
const updateDescription = async (description) => {
  console.log("description", description);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!description) {
    console.log(`Please enter a description to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on(
        "descriptionUpdated",
        (receiver, timestamp, metadata_table_id, description, token_id) => {
          console.log("Receiver :", receiver);

          updatedAt.value = moment.unix(timestamp).toString();
          console.log("Updated At :", traitUpdatedAt.value);

          const metadataTableId = metadata_table_id.toNumber();
          console.log("Metadata Table Id :", metadataTableId);

          const tokenId = token_id.toNumber();
          console.log("Token Id :", tokenId);

          const descriptionNew = description.toString();
          console.log("Description :", descriptionNew);

          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_description(
        BigNumber.from(tokenId.value),
        description.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the description %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update address of Mojo Creators NFT
 */
const updateAddress = async (address) => {
  console.log("address", address);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!address) {
    console.log(`Please enter a address to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on("addressUpdated", (receiver, timestamp, metadata_table_id, address, token_id) => {
        console.log("Receiver :", receiver);

        updatedAt.value = moment.unix(timestamp).toString();
        console.log("Updated At :", traitUpdatedAt.value);

        const metadataTableId = metadata_table_id.toNumber();
        console.log("Metadata Table Id :", metadataTableId);

        const tokenId = token_id.toNumber();
        console.log("Token Id :", tokenId);

        const addressNew = address.toString();
        console.log("Address :", addressNew);

        /* Stop loading */
        store.setLoading(false);
      });

      let tx = await contract.update_address(
        BigNumber.from(tokenId.value),
        description.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the Account Address %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update slogan of Mojo Creators NFT
 */
const updateSlogan = async (slogan) => {
  console.log("slogan", slogan);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!slogan) {
    console.log(`Please enter a slogan to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on("sloganUpdated", (receiver, timestamp, metadata_table_id, slogan, token_id) => {
        console.log("Receiver :", receiver);

        updatedAt.value = moment.unix(timestamp).toString();
        console.log("Updated At :", traitUpdatedAt.value);

        const metadataTableId = metadata_table_id.toNumber();
        console.log("Metadata Table Id :", metadataTableId);

        const tokenId = token_id.toNumber();
        console.log("Token Id :", tokenId);

        const sloganNew = slogan.toString();
        console.log("Slogan :", sloganNew);

        /* Stop loading */
        store.setLoading(false);
      });

      let tx = await contract.update_slogan(
        BigNumber.from(tokenId.value),
        description.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the Slogan %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update profile_img of Mojo Creators NFT
 */
const updateProfileImg = async (profile_img) => {
  console.log("Profile image : ", profile_img);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!profile_img) {
    console.log(`Please enter a profile image to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on(
        "profileImgUpdated",
        (receiver, timestamp, metadata_table_id, profile_img, token_id) => {
          console.log("Receiver :", receiver);

          updatedAt.value = moment.unix(timestamp).toString();
          console.log("Updated At :", traitUpdatedAt.value);

          const metadataTableId = metadata_table_id.toNumber();
          console.log("Metadata Table Id :", metadataTableId);

          const tokenId = token_id.toNumber();
          console.log("Token Id :", tokenId);

          const profile_imgNew = profile_img.toString();
          console.log("Profile Image :", profile_imgNew);

          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_profile_img(
        BigNumber.from(tokenId.value),
        profile_img.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the Slogan %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update banner_img of Mojo Creators NFT
 */
const updateBannerImg = async (banner_img) => {
  console.log("Banner image : ", banner_img);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!banner_img) {
    console.log(`Please enter a profile image to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on(
        "profileImgUpdated",
        (receiver, timestamp, metadata_table_id, banner_img, token_id) => {
          console.log("Receiver :", receiver);

          updatedAt.value = moment.unix(timestamp).toString();
          console.log("Updated At :", traitUpdatedAt.value);

          const metadataTableId = metadata_table_id.toNumber();
          console.log("Metadata Table Id :", metadataTableId);

          const tokenId = token_id.toNumber();
          console.log("Token Id :", tokenId);

          const banner_imgNew = banner_img.toString();
          console.log("Banner Image :", banner_imgNew);

          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_banner_img(
        BigNumber.from(tokenId.value),
        banner_img.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the Banner Image %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update website of Mojo Creators NFT
 */
const updateWebsite = async (website) => {
  console.log("Website : ", website);

  if (!tokenId.value) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!website) {
    console.log(`Please enter a website url to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on("websiteUpdated", (receiver, timestamp, metadata_table_id, website, token_id) => {
        console.log("Receiver :", receiver);

        updatedAt.value = moment.unix(timestamp).toString();
        console.log("Updated At :", traitUpdatedAt.value);

        const metadataTableId = metadata_table_id.toNumber();
        console.log("Metadata Table Id :", metadataTableId);

        const websiteNew = website.toString();
        console.log("Banner Image :", websiteNew);

        const tokenId = token_id.toNumber();
        console.log("Token Id :", tokenId);

        /* Stop loading */
        store.setLoading(false);
      });

      let tx = await contract.update_website(
        BigNumber.from(tokenId.value),
        website.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c We just updated the website Url %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Add a new attribute to a Tableland NFT
 */
const AddNewAttribute = async () => {
  if (!tokenId.value) {
    console.log(`Error, no NFT token id received!`);
    return;
  }
  if (!traitIcon.value) {
    console.log(`Please enter a trait icon to continue!`);
    return;
  }
  if (!traitDisplayType.value) {
    console.log(`Please enter a trait display type to continue!`);
    return;
  }
  if (!traitType.value) {
    console.log(`Please enter a trait type to continue!`);
    return;
  }
  if (!traitValue.value) {
    console.log(`Please enter a value for the trait to continue!`);
    return;
  }
  store.setMinting(false);
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);

      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See newAttributeAdded emitted from our smart contract add_new_attribute function
       */
      contract.on("newAttributeAdded", (receiver, timestamp, token_id, trait_id) => {
        console.log("Receiver :", receiver);

        traitCreatedAt.value = moment.unix(timestamp).toString();
        console.log("Trait Created At :", traitCreatedAt.value);

        traitTokenId.value = token_id.toNumber();
        console.log("Trait TokenId :", traitTokenId.value);

        traitId.value = trait_id.toNumber();
        console.log("Trait Id :", traitId.value);

        /* Add new Trait to our Array for UI */
        attributes.value = attributes.value.concat({
          token_id: traitTokenId.value,
          trait_id: traitId.value,
          icon: traitIcon.value,
          display_type: traitDisplayType.value,
          trait_type: traitType.value,
          trait_value: traitValue.value,
          created_at: traitCreatedAt.value,
        });
        traitTokenId.value = null;
        traitId.value = null;
        traitIcon.value = "";
        traitDisplayType.value = "";
        traitType.value = "";
        traitValue.value = "";
        traitCreatedAt.value = "";
        store.setLoading(false);
      });

      let tx = await contract.add_new_attribute(
        BigNumber.from(tokenId.value),
        traitIcon.value.toString(),
        traitDisplayType.value.toString(),
        traitType.value.toString(),
        traitValue.value.toString()
      );

      const stylesMining = ["color: black", "background: yellow"].join(";");
      console.log("%c Adding new trait attribute... please wait!  %s", stylesMining, tx.hash);

      //wait until a block containing our transaction has been mined and confirmed.
      //new_attribute_added event has been emitted .
      const receipt = await tx.wait();

      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c🍵 We just added new attribute %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT added new attribute, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Show NFT Metatdata Trait to Edit
 * Traits start at 0 on mint, the created date is the first trait added
 */
const editTrait = (value) => {
  if (showTrait.value === value) {
    showTrait.value = 1;
  } else {
    showTrait.value = value;
  }
};

/**
 * Update trait icon of Tableland NFT
 */
const updateTraitIcon = async (attribute) => {
  console.log("attribute", attribute);
  if (!attribute.token_id) {
    console.log(`Please enter a token id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!attribute.trait_id) {
    console.log(`Please enter a trait id to continue!`);
    return;
  }
  if (!attribute.icon) {
    console.log(`Please enter a trait icon url to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on(
        "traitIconUpdated",
        (receiver, timestamp, attributes_table_id, icon, token_id, trait_id) => {
          console.log("Receiver :", receiver);

          traitUpdatedAt.value = moment.unix(timestamp).toString();
          console.log("Trait Updated At :", traitUpdatedAt.value);

          traitTableId.value = attributes_table_id.toNumber();
          console.log("Trait Attributes Table Id :", traitTableId.value);

          traitIcon.value = icon.toString();
          console.log("Trait Icon Url :", traitIcon.value);

          traitTokenId.value = token_id.toNumber();
          console.log("Trait Token Id :", traitTokenId.value);

          traitId.value = trait_id.toNumber();
          console.log("Trait Id :", traitId.value);

          /* Update our traits Array */
          const attribute = attributes.value.find((object) => {
            return object.trait_id === traitId.value;
          });
          console.log(attribute);
          if (attribute !== undefined) {
            console.log("attribute.icon", attribute.icon);
            attribute.icon = traitIcon.value;
            console.log("attribute.icon", attribute.icon);
          }
          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_icon(
        BigNumber.from(traitTokenId.value),
        BigNumber.from(traitId.value),
        traitIcon.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c🍵 We just updated a trait icon url %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update trait display type of a Tableland NFT
 */
const updateTraitDisplayType = async (attribute) => {
  console.log("attribute", attribute);

  if (!attribute.token_id) {
    console.log(`Please enter a tokenId to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!attribute.trait_id) {
    console.log(`Please enter a trait id to continue!`);
    return;
  }
  if (!attribute.display_type) {
    console.log(`Please enter a trait display type to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitDisplayTypeUpdated emitted from our smart contract update_display_type function
       */
      contract.on(
        "traitDisplayTypeUpdated",
        (receiver, timestamp, attributes_table_id, display_type, token_id, trait_id) => {
          console.log("Receiver :", receiver);

          traitUpdatedAt.value = moment.unix(timestamp).toString();
          console.log("Trait Created At :", traitUpdatedAt.value);

          traitTableId.value = attributes_table_id.toNumber();
          console.log("Trait Attributes Table Id :", traitTableId.value);

          traitDisplayType.value = display_type.toString();
          console.log("Trait Display Type :", traitDisplayType.value);

          traitTokenId.value = token_id.toNumber();
          console.log("Trait Token Id :", traitTokenId.value);

          traitId.value = trait_id.toNumber();
          console.log("Trait Id :", traitId.value);

          /* Update our traits Array */
          const attribute = attributes.value.find((object) => {
            return object.trait_id === traitId.value;
          });
          console.log(attribute);
          if (attribute !== undefined) {
            console.log("attribute.display_type", attribute.display_type);
            attribute.display_type = traitDisplayType.value;
            console.log("attribute.display_type", attribute.display_type);
          }
          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_display_type(
        BigNumber.from(traitTokenId.value),
        BigNumber.from(traitId.value),
        traitDisplayType.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c🍵 just updated a trait display type %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update trait type of a Tableland NFT
 */
const updateTraitType = async (attribute) => {
  console.log("attribute", attribute);
  if (!attribute.token_id) {
    console.log(`Please enter a tokenId to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!attribute.trait_id) {
    console.log(`Error, no trait id found!`);
    return;
  }
  if (!attribute.trait_type) {
    console.log(`Please enter a trait type to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);
      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See traitTypeUpdated emitted from our smart contract update_trait_type function
       */
      contract.on(
        "traitTypeUpdated",
        (receiver, timestamp, attributes_table_id, trait_type, token_id, trait_id) => {
          console.log("Receiver :", receiver);

          traitUpdatedAt.value = moment.unix(timestamp).toString();
          console.log("Trait Created At :", traitUpdatedAt.value);

          traitTableId.value = attributes_table_id.toNumber();
          console.log("Trait Table Id :", traitTableId.value);

          traitType.value = trait_type.toString();
          console.log("Trait Type :", traitType.value);

          traitTokenId.value = token_id.toNumber();
          console.log("Trait TokenId :", traitTokenId.value);

          traitId.value = trait_id.toNumber();
          console.log("Trait Id :", traitId.value);

          /* Update our traits Array */
          const attribute = attributes.value.find((object) => {
            return object.trait_id === traitId.value;
          });
          console.log(attribute);
          if (attribute !== undefined) {
            console.log("attribute.trait_type", attribute.trait_type);
            attribute.trait_type = traitType.value;
            console.log("attribute.trait_type", attribute.trait_type);
          }
          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_trait_type(
        BigNumber.from(traitTokenId.value),
        BigNumber.from(traitId.value),
        traitType.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c🍵 just updated a trait type %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated a trait type, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Update trait value of a Tableland NFT
 */
const updateTraitValue = async (attribute) => {
  console.log("Attribute:", attribute);

  if (!attribute.token_id) {
    notyf.error(`Please enter a trait id to continue!`);
    return;
  }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!attribute.trait_id) {
    notyf.error(`Please enter a trait id to continue!`);
    return;
  }
  if (!attribute.trait_value) {
    notyf.error(`Please enter a value for the trait to continue!`);
    return;
  }
  /* Start loading */
  store.setLoading(true);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(mojoCreatorsContractAddress, contractAbi.abi, signer);

      /**
       *  Receive Emitted Event from Smart Contract
       *  @dev See valueUpdated emitted from our smart contract update_value function
       */
      contract.on(
        "valueUpdated",
        (receiver, timestamp, attributes_table_id, trait_value, token_id, trait_id) => {
          console.log("Receiver :", receiver);

          traitUpdatedAt.value = moment.unix(timestamp).toString();
          console.log("Trait Updated At :", traitUpdatedAt.value);

          traitTableId.value = attributes_table_id.toNumber();
          console.log("Trait Table Id :", traitTableId.value);

          traitValue.value = trait_value.toString();
          console.log("Trait Value :", traitValue.value);

          traitTokenId.value = token_id.toNumber();
          console.log("Trait TokenId :", traitTokenId.value);

          traitId.value = trait_id.toNumber();
          console.log("Trait Id :", traitId.value);

          /* Update our traits Array */
          const attribute = attributes.value.find((object) => {
            return object.trait_id === traitId.value;
          });
          console.log(attribute);
          if (attribute !== undefined) {
            console.log("attribute.trait_value", attribute.trait_value);
            attribute.trait_value = traitValue.value;
            console.log("attribute.trait_value", attribute.trait_value);
          }
          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_value(
        BigNumber.from(traitTokenId.value),
        BigNumber.from(traitId.value),
        traitValue.value.toString()
      );

      const receipt = await tx.wait();
      const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
      console.log("%c🍵 just updated value %s ", stylesReceipt, tx.hash);

      /* Check our Transaction results */
      if (receipt.status === 1) {
        /**
         * @dev NOTE: Switch up these links once we go to Production
         * Currently set to use Polygon Mumbai Testnet
         */
        const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
        console.log(
          `%c🧬 NFT updated value, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
          stylesPolygon,
          tx.hash
        );
        store.setLoading(false);
      }
      /* Stop loading */
      store.setLoading(false);
      return;
    } else {
      /* Stop loading */
      store.setLoading(false);
      console.log("Ethereum object doesn't exist!");
    }
  } catch (error) {
    /* Stop loading */
    store.setLoading(false);
    console.log("error", error);
  }
};

/**
 * Cancel NFT Mint
 */
const cancelMint = () => {
  /* File Uploader Refs */
  fileRef.value = null;
  isDragged.value = false;
  finished.value = 0;
  isUploading.value = false;
  cid.value = "";
  audioVideoType.value = "";
  size.value = "";
  /* Reset our NFT Metadata Form Values */
  tokenId.value = "";
  name.value = "";
  description.value = "";
  imageUrl.value = "";
  slogan.value = "";
  accountAddress.value = "";
  website.value = "";
  profile_img.value = "";
  banner_img.value = "";
  createdAt.value = "";
  /* Reset Metadata Attributes */
  attributes.value = [];
  traitTableId.value = null;
  traitTokenId.value = null;
  traitId.value = null;
  traitIcon.value = "";
  traitDisplayType.value = "";
  traitType.value = "";
  traitValue.value = "";
  traitCreatedAt.value = "";
  traitUpdatedAt.value = "";
  approvedMint.value = false;
  /* Stop All Loaders */
  store.setLoading(false);
  store.setMinting(false);
};

/**
 * Approve Tableland NFT Mint
 */
const ConfirmApprovedMint = (value) => {
  approvedMint.value = value;
};

/**
 * Drag n Drop File Manager
 */
const onDropHandler = ($event) => {
  if (isUploading.value) return false;
  isDragged.value = false;
  fileRef.value.files = $event.dataTransfer.files;
  onFileChangedHandler();
};
const openSelectFile = () => {
  if (isUploading.value) return false;
  fileRef.value.click();
};
const onDragEnter = () => {
  isDragged.value = true;
};
const onDragLeave = () => {
  isDragged.value = false;
};

/**
 * @param {File} file
 * @returns {Object}
 */
const uploadFileHandler = async (file) => {
  store.setLoading(true);
  /**
   * @dev Can try NFT.Storage here instead
   */
  const uploadResult = await uploadBlob(file);

  finished.value++;
  const { error } = uploadResult;
  if (error && error instanceof Error) {
    notyf.error(error.message);
    store.setLoading(false);
    return uploadResult;
  }
  /* Set our NFT Metadata Form Values using IPFS best practises */
  cid.value = uploadResult.data.cid;
  /* Strip image type off our name eg, .png, .jpeg */
  // name.value = uploadResult.data.file.name.substring(
  //   0,
  //   uploadResult.data.file.name.lastIndexOf(".")
  // );
  /* Generate and IPFS URI for NFT's */
  imageUrl.value = generateLink(uploadResult.data);

  /* Set details from file upload */
  audioVideoType.value = uploadResult.data.file.type;
  size.value = fileSize(uploadResult.data.file.size);
  createdAt.value = uploadResult.data.file.created_at;
  store.setLoading(false);
  return uploadResult;
};

/*
 * On file change will update our NFT Metadata
 */
const onFileChangedHandler = async () => {
  isUploading.value = true;
  store.addNftFiles(...fileRef.value.files);
  const files = store.filesNft.map((file) => uploadFileHandler(file));
  try {
    let results = await Promise.all(files);
    const successfully = results.filter(({ error }) => !error);
    console.log("Successfully uploaded", successfully[0].data);
    if (successfully.length > 0) {
      notyf.success(`${successfully.length} files successfully uploaded to IPFS`);
    }
    if (successfully.length === 0) {
      notyf.error(`Oops! An error occurred while processing your files.`);
    }
    store.addNftResults(...successfully.map(({ error, data: file }) => file));
    store.resetNftFiles();
    fileRef.value.value = null;
  } catch (error) {
    finished.value = 0;
    isUploading.value = false;
  } finally {
    finished.value = 0;
    isUploading.value = false;
  }
};

/* Computed values for our uploader */
const fileCount = computed(() => {
  return store.filesNft.length;
});

const result = computed(() => {
  return {
    count: store.nftResults.length,
    size: store.nftResults.reduce((sum, result) => {
      return sum + result.file.size;
    }, 0),
  };
});

/* Checks what type of NFT we have image, mp3, mp4, etc. */
const getUrlProtocol = (url) => {
  let protocol = url.endsWith("mp4") ? 5 : 0;
  if (protocol == 0) protocol = url.endsWith("mp3") ? 6 : 0;
  if (protocol == 0) protocol = url.endsWith("gif") ? 7 : 0;
  if (protocol == 0) protocol = url.startsWith("http://") ? 1 : 0;
  if (protocol == 0) protocol = url.startsWith("https://") ? 2 : 0;
  if (protocol == 0) protocol = url.startsWith("ipfs://") ? 3 : 0;
  if (protocol == 0) protocol = url !== "" ? 4 : 0;
  switch (protocol) {
    case 1:
      return url;
    case 2:
      return url;
    case 3:
      return "https://ipfs.io/ipfs/" + url.substring(7);
    case 4:
      return generateLink(url);
    case 5:
      return "mp4";
    case 6:
      return "mp3";
    case 7:
      return url;
    case 0:
      return "Not http or https";
  }
};

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
  await authenticateNFT();
  await fetchTokens();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#account {
  width: 100%;
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
    height: 100%;
    display: flex;
    flex-direction: column;
    align-content: center;
    justify-content: flex-start;
    align-items: center;
    padding: 40px;

    @include breakpoint($break-ssm) {
      width: 100%;
    }

    .account-connect-card {
      min-width: 300px;
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
      padding: 30px 20px 10px;
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
      .contract-address {
        font-size: 9px;
        text-transform: uppercase;
      }

      p {
        line-height: 1.7;
        margin-bottom: 20px;
        text-align: center;
      }

      .home-button {
        color: #fff;
        background-color: $mojo-blue;
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
  .right {
    width: 100%;
    height: inherit;
    display: flex;
    flex-direction: column;
    align-content: center;
    justify-content: flex-start;
    align-items: flex-end;
    padding: 40px 20px 40px 0;

    @include breakpoint($break-ssm) {
      width: 100%;
    }

    .account-card {
      width: 96%;
      height: auto;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      align-content: center;
      background: #fff;
      border: 4px solid var(--gradient-100);
      box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
      border-radius: 10px;
      padding: 0 0 10px 0;
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
          width: 100%;
          color: $black;
          font-size: 34px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: left;
          margin: 0;
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

      .form-container {
        display: flex;
        width: 350px;
        height: auto;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px 0 10px;

        h2 {
          font-size: 30px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          text-align: center;
          padding-bottom: 2px;
          text-decoration: none;
          border-bottom: 1px solid;
          margin: 0 auto 20px;

          @include breakpoint($break-ssm) {
            font-size: 1.4rem;
            line-height: 1.5rem;
          }
        }

        .panel-upload--dropzone {
          width: 100%;
          position: relative;
          display: flex;
          align-content: center;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          overflow: hidden;

          &.active {
            > * {
              pointer-events: none;
            }

            .dropzone-box {
              background-color: rgba(0, 0, 0, 0.2);
            }
          }

          input {
            display: none;
          }

          .dropzone-box {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            color: #1a1a1a;
            background-color: #fdfdfd;
            border: 2px solid var(--gradient-100);
            border-radius: 10px;
            letter-spacing: 1px;
            font-size: 14px;
            margin-bottom: 10px;
            padding: 10px;
            text-align: center;

            svg {
              height: 36px;
              width: 36px;
              margin-bottom: 0.25rem;
            }

            span {
              color: #1a1a1a;
              font-size: 0.8rem;
            }
          }

          .dropzone-is-loading {
            opacity: 0;
            position: relative;
            height: 4px;
            display: block;
            width: 150px;
            background-color: var(--gradient-300);
            border-radius: 2px;
            margin: 0.25rem 0 0.35rem 0;
            overflow: hidden;

            &.active {
              opacity: 1;
            }

            .dropzone-loading--bar {
              background-color: var(--gradient-800);

              &:before {
                content: "";
                position: absolute;
                background-color: inherit;
                top: 0;
                left: 0;
                bottom: 0;
                will-change: left, right;
                animation: indeterminate 2.1s cubic-bezier(0.65, 0.815, 0.735, 0.395) infinite;
              }

              &:after {
                content: "";
                position: absolute;
                background-color: inherit;
                top: 0;
                left: 0;
                bottom: 0;
                will-change: left, right;
                animation: indeterminate-short 2.1s cubic-bezier(0.165, 0.84, 0.44, 1) infinite;
                animation-delay: 1.15s;
              }
            }
          }
          .dropzone-details {
            color: #1a1a1a;
            display: flex;
            margin-top: 5px;

            .dropzone-detail {
              color: #1a1a1a;
              font-size: 0.8rem;
              background-color: var(--gradient-300);
              border-radius: 1rem;
              padding: 0.4rem 0.8rem;
              margin-right: 0.6rem;
            }
          }
        }

        .file-view-link {
          position: relative;
          background: $black;
          border: none;
          border-radius: 30px;
          padding: 0.3rem 0.7rem;
          margin: -48px -270px 20px 0;
          cursor: pointer;

          a {
            color: $white;
            font-family: "PPNeueMachina", inter, -apple-system, system-ui, "Segoe UI", Helvetica,
              "Apple Color Emoji", Arial, sans-serif, "Segoe UI Emoji", "Segoe UI Symbol";
            letter-spacing: 0.05786em;
            font-style: normal;
            font-size: 0.8rem;
            text-align: center;
            transition: 0.4s;

            &:hover {
              color: $mojo-blue;
            }
          }
        }

        .input-row {
          position: relative;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          align-items: left;
          margin-bottom: 10px;
        }

        label {
          color: $mojo-blue;
          font-style: normal;
          font-weight: 800;
          font-size: 20px;
          line-height: 24px;
          letter-spacing: 0.1em;
          margin: 0 0 2px 5px;
        }

        input {
          width: 100%;
          color: #1a1a1a;
          background-color: #fdfdfd;
          border: 2px solid var(--gradient-100);
          border-radius: 10px;
          letter-spacing: 1px;
          font-size: 14px;
          width: 300px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: left;

          @include breakpoint($break-sm) {
            width: 300px;
          }

          @include breakpoint($break-md) {
            width: 300px;
          }

          @include breakpoint($break-xxl) {
            width: 300px;
          }
        }

        input::placeholder {
          color: #a8a8a8;
          letter-spacing: 1px;
        }

        input:read-only {
          color: #1a1a1a;
          border: 2px dashed #e0e0e0;
          letter-spacing: 2px;
          cursor: not-allowed;
        }

        input:focus {
          border: 2px solid $mojo-light-blue;
          outline: none;
        }

        .select-row {
          position: relative;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          align-items: left;
          margin-bottom: 15px;
        }

        select {
          display: inline-block;
          color: #1a1a1a;
          background-color: #fdfdfd;
          border: 2px solid var(--gradient-100);
          border-radius: 10px;
          letter-spacing: 1px;
          font-size: 14px;
          width: 328px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: center;

          /* reset */
          margin: 0;
          -webkit-box-sizing: border-box;
          -moz-box-sizing: border-box;
          box-sizing: border-box;
          appearance: none;
          -webkit-appearance: none;
          -moz-appearance: none;

          background-image: linear-gradient(45deg, transparent 50%, gray 50%),
            linear-gradient(135deg, gray 50%, transparent 50%),
            linear-gradient(to right, #ccc, #ccc);
          background-position: calc(100% - 20px) calc(1em + 2px), calc(100% - 15px) calc(1em + 2px),
            calc(100% - 2.5em) 0.5em;
          background-size: 5px 5px, 5px 5px, 1px 1.5em;
          background-repeat: no-repeat;

          @include breakpoint($break-sm) {
            width: 325px;
          }

          @include breakpoint($break-md) {
            width: 325px;
          }

          @include breakpoint($break-xxl) {
            width: 325px;
          }
        }

        select:focus {
          border: 2px solid #2bb5f0;
          background-image: linear-gradient(45deg, green 50%, transparent 50%),
            linear-gradient(135deg, transparent 50%, green 50%),
            linear-gradient(to right, #ccc, #ccc);
          background-position: calc(100% - 15px) 1em, calc(100% - 20px) 1em,
            calc(100% - 2.5em) 0.5em;
          background-size: 5px 5px, 5px 5px, 1px 1.5em;
          background-repeat: no-repeat;
          outline: none;
          cursor: pointer;
        }

        select:-moz-focusring {
          color: transparent;
          text-shadow: 0 0 0 #000;
        }

        .grey {
          color: #a8a8a8 !important;
          letter-spacing: 1px;
        }

        textarea {
          color: #1a1a1a;
          background-color: #fdfdfd;
          border: 2px solid var(--gradient-100);
          border-radius: 10px;
          letter-spacing: 1px;
          font-size: 14px;
          width: 300px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: center;
        }

        textarea::placeholder {
          color: #a8a8a8;
          letter-spacing: 1px;
        }

        textarea:focus {
          border: 2px solid $mojo-light-blue;
          outline: none;
        }
        .button-container {
          margin: 0 auto;
          display: flex;
          flex-direction: row;
          align-content: center;
          justify-content: space;
          align-items: center;

          .skip-button {
            color: $white;
            background-color: $black;
            font-size: 18px;
            font-weight: bold;
            width: auto;
            max-width: 300px;
            height: 55px;
            border: 2px solid $black;
            padding-left: 20px;
            padding-right: 20px;
            border-radius: 10px;
            margin-left: 1%;
            cursor: pointer;
          }

          .attr-button {
            color: #fff;
            background-color: #8d50f5;
            font-size: 18px;
            font-weight: bold;
            width: auto;
            max-width: 360px;
            height: 55px;
            border: 0;
            padding-left: 21px;
            padding-right: 21px;
            border-radius: 10px;
            margin-left: 2%;
            cursor: pointer;
          }

          .attr-button:disabled {
            background: #c6c6c6;
            color: #101010;
            cursor: not-allowed;
          }

          .back-button-blue {
            color: #1c8bfe;
            background-color: #fff;
            font-size: 18px;
            font-weight: bold;
            width: auto;
            max-width: 300px;
            height: 55px;
            border: 2px solid #1c8bfe;
            padding-left: 20px;
            padding-right: 20px;
            border-radius: 10px;
            margin-right: 1%;
            cursor: pointer;
          }

          .back-button-purple {
            color: #8d50f5;
            background-color: #fff;
            font-size: 18px;
            font-weight: bold;
            width: auto;
            height: 55px;
            border: 2px solid #8d50f5;
            padding-left: 20px;
            padding-right: 20px;
            border-radius: 10px;
            margin-right: 10px;
            cursor: pointer;
          }

          .mint-button {
            color: #fff;
            background-color: #08d0a5;
            font-size: 18px;
            font-weight: bold;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 57px;
            padding-right: 57px;
            margin: 10px 1% 10px 0;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $mojo-blue;
            }
          }

          .mint-button:disabled {
            background: #c6c6c6;
            color: #101010;
            cursor: not-allowed;
          }

          .mint-done-button {
            color: $black;
            background-color: $mojo-green;
            font-size: 18px;
            font-weight: bold;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 65px;
            padding-right: 65px;
            margin: 10px 1% 10px 0;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $mojo-blue;
            }
          }

          .restart-button {
            color: $white;
            background-color: $mojo-blue;
            font-size: 18px;
            font-weight: bold;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 40px;
            padding-right: 40px;
            margin: 10px 0 10px 1%;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
          }

          .external-url-button {
            color: #fff;
            background-color: #e9429b;
            font-size: 18px;
            font-weight: bold;
            width: 100%;
            max-width: 300px;
            height: 55px;
            border: 0;
            padding-left: 87px;
            padding-right: 87px;
            border-radius: 10px;
            cursor: pointer;
          }

          .external-url-button:disabled {
            background: #c6c6c6;
            color: #101010;
            cursor: not-allowed;
          }

          .update-button {
            color: #fff;
            background-color: #1c8bfe;
            font-size: 18px;
            font-weight: bold;
            width: auto;
            max-width: 300px;
            height: 55px;
            border: 0;
            padding-left: 43px;
            padding-right: 43px;
            border-radius: 10px;
            cursor: pointer;
          }

          .update-button:disabled {
            background: #c6c6c6;
            color: #101010;
            cursor: not-allowed;
          }
        }
      }

      .nft-banner-image {
        position: relative;
        width: 97%;
        min-height: 200px;
        background: #f4f4f4;
        border: 1px solid #1a1a1a;
        box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
        border-radius: 10px;
        overflow: hidden;
        margin: 2% 1% 20px 1%;
        padding: 0;

        img,
        svg {
          width: 100%;
          height: auto;
          object-fit: contain;
          overflow: hidden;
        }
        .nft-banner-image-edit-button {
          position: absolute;
          top: 5px;
          left: 5px;
          color: $mojo-blue;
          background-color: $white;
          font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
            "Helvetica Neue", sans-serif;
          font-style: normal;
          font-weight: 800;
          font-size: 11px;
          line-height: 14px;
          text-align: center;
          padding: 4px 6px;
          height: auto;
          border: 0;
          border-radius: 10px;
          margin: 0;
          transition: 0.4s;
          cursor: pointer;

          &:hover {
            color: $black;
          }
        }
        .nft-banner-image-add-button {
          position: absolute;
          top: 5px;
          left: 5px;
          color: $mojo-blue;
          background-color: $white;
          font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
            "Helvetica Neue", sans-serif;
          font-style: normal;
          font-weight: 800;
          font-size: 11px;
          line-height: 14px;
          text-align: center;
          padding: 4px 6px;
          height: auto;
          border: 1px solid $mojo-blue;
          border-radius: 10px;
          margin: 0;
          transition: 0.4s;
          cursor: pointer;
          &:hover {
            color: $black;
          }
        }
      }

      .nft-modal-card {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;
        box-sizing: border-box;
        padding: 0;

        .row {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: flex-start;
          justify-content: flex-start;
          align-items: flex-start;

          .nft-profile-image {
            position: relative;
            min-width: 200px;
            min-height: 200px;
            background: #f4f4f4;
            border: 1px solid #1a1a1a;
            box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
            border-radius: 10px;
            margin: 0 2% 0 1%;
            overflow: hidden;
            img,
            svg {
              width: 100%;
              height: 100%;
              object-fit: contain;
              overflow: hidden;
            }
            .nft-profile-image-edit-button {
              position: absolute;
              top: 5px;
              left: 5px;
              color: $mojo-blue;
              background-color: $white;
              font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
                "Helvetica Neue", sans-serif;
              font-style: normal;
              font-weight: 800;
              font-size: 11px;
              line-height: 14px;
              text-align: center;
              padding: 4px 6px;
              height: auto;
              border: 0;
              border-radius: 10px;
              margin: 0;
              transition: 0.4s;
              cursor: pointer;
              &:hover {
                color: $black;
              }
            }

            .nft-profile-image-add-button {
              position: absolute;
              top: 5px;
              left: 5px;
              color: $mojo-blue;
              background-color: $white;
              font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
                "Helvetica Neue", sans-serif;
              font-style: normal;
              font-weight: 800;
              font-size: 11px;
              line-height: 14px;
              text-align: center;
              padding: 4px 6px;
              height: auto;
              border: 1px solid $mojo-blue;
              border-radius: 10px;
              margin: 0;
              transition: 0.4s;
              cursor: pointer;
              &:hover {
                color: $black;
              }
            }
          }

          .column {
            width: 100%;
            position: relative;
            display: flex;
            flex-direction: column;
            align-content: flex-start;
            justify-content: flex-start;
            align-items: flex-start;

            .nft-modal-title {
              width: 100%;
              margin: 0 0 10px 0;
              input {
                width: 94%;
                color: $black;
                background-color: #fff;
                border: 1px solid $black;
                letter-spacing: 1px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 5px;
                padding: 7px 0 0 7px;
                text-align: left;
              }

              input::placeholder {
                color: #a8a8a8;
                letter-spacing: 1px;
              }

              input:focus {
                border: 1px solid $mojo-light-blue;
                outline: none;
              }
            }
            .nft-modal-address {
              width: 100%;
              margin: 0 0 10px 0;
              input {
                width: 94%;
                color: $black;
                background-color: #fff;
                border: 1px solid $black;
                letter-spacing: 1px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 5px;
                padding: 7px 0 0 7px;
                text-align: left;
                text-transform: uppercase;
              }

              input::placeholder {
                color: #a8a8a8;
                letter-spacing: 1px;
              }

              input:focus {
                border: 1px solid $mojo-light-blue;
                outline: none;
              }
            }

            .nft-modal-website {
              width: 100%;
              margin: 0 0 10px 0;
              input {
                width: 94%;
                color: $black;
                background-color: #fff;
                border: 1px solid $black;
                letter-spacing: 1px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 5px;
                padding: 7px 0 0 7px;
                text-align: left;
              }

              input::placeholder {
                color: #a8a8a8;
                letter-spacing: 1px;
              }

              input:focus {
                border: 1px solid $mojo-light-blue;
                outline: none;
              }
            }

            .nft-modal-slogan {
              width: 100%;
              margin: 0 0 10px 0;
              input {
                width: 94%;
                height: 30px;
                color: $black;
                background-color: #fff;
                border: 1px solid $black;
                letter-spacing: 1px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 5px;
                padding: 7px 0 0 7px;
                text-align: left;
              }

              input::placeholder {
                color: #a8a8a8;
                letter-spacing: 1px;
              }

              input:focus {
                border: 1px solid $mojo-light-blue;
                outline: none;
              }
            }

            .nft-modal-description {
              width: 100%;
              margin: 0 0 10px 0;
              textarea {
                width: 94%;
                color: $black;
                background-color: #fff;
                border: 1px solid $black;
                letter-spacing: 1px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 5px;
                padding: 7px 0 0 7px;
                text-align: left;
              }

              textarea::placeholder {
                color: #a8a8a8;
                letter-spacing: 1px;
              }

              textarea:focus {
                border: 1px solid $mojo-light-blue;
                outline: none;
              }
            }

            .nft-add-attribute {
              width: 100%;
              margin: 0 0 10px 0;

              input {
                width: 94%;
                height: 30px;
                color: $black;
                background-color: #fff;
                border: 1px solid $black;
                letter-spacing: 1px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 5px;
                padding: 7px 0 0 7px;
                text-align: left;
              }

              input::placeholder {
                color: #a8a8a8;
                letter-spacing: 1px;
              }

              input:focus {
                border: 1px solid $mojo-light-blue;
                outline: none;
              }
            }
          }
        }

        .nft-modal-video {
          position: relative;
          width: 100%;
          max-width: 500px;
          margin: 0 auto;
          padding: 0;
          overflow: hidden;
          box-sizing: border-box;
          background: #f4f4f4;
          border-radius: 10px;
          .nft-modal-image-edit-button {
            position: absolute;
            top: 5px;
            left: 5px;
            color: $mojo-blue;
            background-color: $white;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 11px;
            line-height: 14px;
            text-align: center;
            padding: 4px 6px;
            height: auto;
            border: 0;
            border-radius: 10px;
            margin: 0;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
          }
          .nft-image-image-add-button {
            position: absolute;
            top: 5px;
            left: 5px;
            color: $mojo-blue;
            background-color: $white;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 11px;
            line-height: 14px;
            text-align: center;
            padding: 4px 6px;
            height: auto;
            border: 1px solid $mojo-blue;
            border-radius: 10px;
            margin: 0;
            transition: 0.4s;
            cursor: pointer;
            &:hover {
              color: $black;
            }
          }
        }

        .nft-modal-image {
          position: relative;
          width: 100%;
          max-width: 410px;
          margin: 0 auto;
          padding: 0;
          overflow: hidden;
          box-sizing: border-box;
          background: #f4f4f4;
          border-radius: 10px;

          img,
          svg {
            width: 100%;
            height: 100%;
            object-fit: contain;
            overflow: hidden;
          }
          .nft-modal-image-edit-button {
            position: absolute;
            top: 5px;
            left: 5px;
            color: $mojo-blue;
            background-color: $white;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 11px;
            line-height: 14px;
            text-align: center;
            padding: 4px 6px;
            height: auto;
            border: 0;
            border-radius: 10px;
            margin: 0;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
          }
          .nft-modal-image-add-button {
            position: absolute;
            top: 5px;
            left: 5px;
            color: $mojo-blue;
            background-color: $white;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 11px;
            line-height: 14px;
            text-align: center;
            padding: 4px 6px;
            height: auto;
            border: 1px solid $mojo-blue;
            border-radius: 10px;
            margin: 0;
            transition: 0.4s;
            cursor: pointer;
            &:hover {
              color: $black;
            }
          }
        }

        .nft-modal-add-attribute {
          width: 100%;
          margin: 0 0 10px 0;
          input {
            width: 44%;
            height: 30px;
            color: $black;
            background-color: #fff;
            border: 1px solid $black;
            letter-spacing: 1px;
            font-size: 12px;
            line-height: 20px;
            margin-bottom: 5px;
            padding: 7px 0 0 7px;
            text-align: left;
          }

          input::placeholder {
            color: #a8a8a8;
            letter-spacing: 1px;
          }

          input:focus {
            border: 1px solid $mojo-light-blue;
            outline: none;
          }
        }

        .nft-modal-edit-attributes {
          color: #1a1a1a;
          width: 100%;
          font-size: 14px;
          font-weight: normal;
          text-align: center;
          margin: 10px auto 0;

          .nft-attribute-cards {
            display: flex;
            flex-direction: row wrap;
            align-content: flex-start;
            justify-content: space-between;
            align-items: flex-start;

            .nft-attribute-card {
              width: 86%;
              color: $black;
              background-color: #fff;
              border: 1px solid $mojo-blue;
              border-radius: 10px;
              letter-spacing: 1px;
              font-size: 12px;
              line-height: 20px;
              margin: 0 auto 5px;
              padding: 10px;
              text-align: left;

              .nft-attribute-card-trait {
                display: flex;
                flex-direction: row wrap;
                align-content: flex-start;
                justify-content: space-between;
                align-items: flex-start;

                .edit-button {
                  color: $mojo-blue;
                  background-color: $white;
                  font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
                    "Helvetica Neue", sans-serif;
                  font-style: normal;
                  font-weight: 800;
                  font-size: 11px;
                  line-height: 14px;
                  text-align: right;
                  width: 30px;
                  padding: 4px 5px;
                  height: auto;
                  border: 0;
                  margin: 0 0 0 5px;
                  transition: 0.4s;
                  cursor: pointer;

                  &:hover {
                    color: $black;
                  }
                }
              }
            }
          }

          .nft-attribute {
            width: 86%;
            margin: 0 auto;
            background: $white;
            border: 1px solid $black;
            border-radius: 10px;
            padding: 5px;

            input {
              width: 100%;
              height: 30px;
              color: $black;
              background-color: #fff;
              border-top: 1px solid $white;
              border-left: 1px solid $white;
              border-right: 1px solid $white;
              border-bottom: 1px solid $black;
              letter-spacing: 1px;
              font-size: 12px;
              line-height: 20px;
              margin-bottom: 5px;
              padding: 7px;
              text-align: center;
            }

            input::placeholder {
              color: #a8a8a8;
              letter-spacing: 1px;
            }

            input:focus {
              border: 1px dashed $mojo-blue;
              outline: none;
            }
          }
        }

        .nft-modal-approve {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: center;
          justify-content: center;
          align-items: center;
          margin-top: 5px;

          .add-button {
            color: $white;
            background-color: $mojo-blue;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 14px;
            line-height: 24px;
            text-align: center;
            width: 200px;
            border-radius: 30px;
            padding: 4px;
            height: auto;
            border: 0;
            margin: 0 5px 0 0;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
          }

          .approve-button {
            color: $white;
            background-color: $mojo-green;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 14px;
            line-height: 24px;
            text-align: center;
            width: 100px;
            border-radius: 30px;
            padding: 4px 12px 5px;
            height: auto;
            border: 0;
            margin: 0 5px 0 5px;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
          }

          .approved-button {
            color: $black;
            background-color: $mojo-blue;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 14px;
            line-height: 24px;
            text-align: center;
            width: 100px;
            border-radius: 30px;
            padding: 4px 12px 5px;
            height: auto;
            border: 0;
            margin: 0 5px 0 5px;
            transition: 0.4s;
            cursor: not-allowed;

            &:hover {
              color: $black;
            }
          }

          .file-image-link {
            background: $black;
            border: none;
            border-radius: 30px;
            padding: 4px 12px 5px;
            margin: 0;
            cursor: pointer;

            a {
              color: $white;
              font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
                "Helvetica Neue", sans-serif;
              font-style: normal;
              font-weight: 800;
              font-size: 14px;
              line-height: 24px;
              text-align: center;
              transition: 0.4s;

              &:hover {
                color: $mojo-blue;
              }
            }
          }

          .file-table-link {
            background: $black;
            border: none;
            border-radius: 30px;
            padding: 4px 12px 5px;
            margin: 0;
            cursor: pointer;

            a {
              color: $white;
              font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
                "Helvetica Neue", sans-serif;
              font-style: normal;
              font-weight: 800;
              font-size: 14px;
              line-height: 24px;
              text-align: center;
              transition: 0.4s;

              &:hover {
                color: $mojo-blue;
              }
            }
          }

          .cancel-button {
            color: $white;
            background-color: $mojo-red;
            font-family: Roboto, Oxygen, Ubuntu, Cantarell, "Fira Sans", "Droid Sans",
              "Helvetica Neue", sans-serif;
            font-style: normal;
            font-weight: 800;
            font-size: 14px;
            line-height: 24px;
            text-align: center;
            width: 100px;
            border-radius: 30px;
            padding: 4px 12px 5px;
            height: auto;
            border: 0;
            margin: 0 0 0 5px;
            transition: 0.4s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
          }
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
