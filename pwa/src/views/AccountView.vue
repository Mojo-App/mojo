<template>
  <section id="account">
    <div class="left">
      <!-- Step 1 : No Metamask Connected  -->
      <div v-if="!account && !isAuthenticated" class="account-connect-card">
        <h2>Account</h2>
        <p>Welcome to Mojo Music, let's get you rockin' ready!</p>
        <p>Please connect your Metamask wallet to get started!</p>
        <p>
          <ConnectWalletButton v-model="account" btnSize="small" />
        </p>
      </div>
      <!-- Step 2: Metamask connected but must Mint mcNFT -->
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
          Thank you for authenticating, you can keep you Mojo Creator profile hip 'n happening right
          here, right now!
        </p>
        <p>
          <button class="home-button" @click="$router.push({ name: 'home' })">home</button>
        </p>
      </div>
    </div>
    <!-- Right Hand Side -->
    <div class="right">
      <!-- Step 2: Mint a Mojo Creators Membership NFT -->
      <div v-if="(account && !isAuthenticated) || mintNew" class="account-card">
        <div class="form-container">
          <h2>Mint Creator NFT</h2>
          <div
            class="panel-upload--dropzone"
            :class="{ active: isDragged }"
            @dragenter="onDragEnter"
            @dragleave="onDragLeave"
            @drop.prevent="onDropHandler($event)"
            @dragover.prevent
          >
            <input type="file" multiple ref="fileRef" @change="onFileChangedHandler()" />
            <div class="dropzone-box" @click="openSelectFile">
              <!-- Uploader Icon -->
              <i-mdi-timer-sand v-if="isUploading" class="icon-color" />
              <i-mdi-upload v-else class="icon-color" />
              <!-- END Uploader Icon -->
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
          <br />
          <div class="input-row">
            <label>Name</label>
            <div class="input-wrapper">
              <input type="text" v-model="name" />
            </div>
          </div>
          <div class="input-row">
            <label>Description</label>
            <div class="textarea-wrapper">
              <textarea v-model="description" rows="5" cols="50"></textarea>
            </div>
          </div>
          <div class="input-row">
            <label>Account Address</label>
            <div class="input-wrapper">
              <input type="text" v-model="accountAddress" />
            </div>
          </div>
          <div class="button-container">
            <button
              class="mint-button"
              :disabled="!name || !description || !accountAddress || !imageUrl"
              @click="mintNFT()"
            >
              {{ minting ? "minting" : "mint" }}
            </button>
            <button class="restart-button" @click="cancelMint()">clear</button>
          </div>
        </div>
      </div>
      <!-- Step 3: Show our Mojo Creator NFTs -->
      <div v-if="account && isAuthenticated && !mintNew" class="account-card">
        <div class="control-panel">
          <button class="mint-new-button" @click="toggleMintNew()">new mint</button>
          <button
            :class="
              mojoMCNFTTokens || showNFTs ? 'nft-showcase-edit-button' : 'nft-showcase-add-button'
            "
            @click="toggleShowNFTs()"
          >
            {{ showNFTs ? "hide list" : "show all" }}
          </button>
          <!-- Some Loading Messages -->

          <div v-if="!loading && showNFTs" class="loading-text">Select a NFT to update</div>
          <div v-else class="loading-text">Update your Mojo Creator NFT</div>
          <!-- END Some Loading Messages -->
        </div>
        <div v-if="mojoMCNFTTokens" class="row token-list">
          <template v-if="showNFTs">
            <template v-for="token in mojoMCNFTTokens" :key="token.tokenId">
              <div class="nft" @click="loadMojoNFT(token.tokenId)">
                <div v-if="token.image && getUrlProtocol(token.image) === 'mp4'" class="nft-video">
                  <video height="240" controls>
                    <source :src="`${token.image}`" type="video/mp4" />
                    <!-- <source :src="`${token.image}`" type="video/ogg" /> -->
                    Your browser does not support the video tag.
                  </video>
                </div>
                <div
                  v-else-if="token.image && getUrlProtocol(token.image) === 'mp3'"
                  class="nft-video"
                >
                  <video height="240" controls>
                    <source :src="getUrlProtocol(token.image)" type="video/mp3" />
                    <!-- <source :src="`${image}`" type="video/ogg" /> -->
                    Your browser does not support the video tag.
                  </video>
                </div>
                <div v-else-if="token.image" class="nft-image">
                  <img :src="`${getUrlProtocol(token.image)}`" :alt="`${token.name}`" />
                </div>
                <div v-else class="nft-error-image">
                  <img src="../assets/images/ImageError.png" alt="No image" />
                </div>
                <div v-if="token.name" class="nft-title">{{ token.tokenId }}. {{ token.name }}</div>
                <div v-else class="nft-title">Nameless</div>
                <!-- <div v-if="token.contract" class="nft-title">Contract : {{ token.contract }}</div> -->
                <!-- <div v-if="token.tokenId" class="nft-title">Token Id : {{ token.tokenId }}</div> -->
                <!-- <div v-if="token.description" class="nft-description">
                  {{ token.description }}
                </div> -->
                <!-- <div v-if="token.external_url" class="nft-external-url">
                  {{ token.external_url }}
                </div> -->
                <!-- <div v-if="token.animation_url" class="nft-animation-url">
                  {{ token.animation_url }}
                </div> -->
                <div v-if="token.attributes" class="nft-attributes">
                  <template v-for="attr in token.attributes" :key="attr.value">
                    <div class="nft-attribute-cards">
                      <div class="nft-attribute-card">
                        <div class="nft-attribute-card-trait">
                          {{ attr.trait_type }} : {{ attr.value }}
                        </div>
                      </div>
                    </div>
                  </template>
                </div>
              </div>
            </template>
          </template>
        </div>
        <div v-if="loading" class="loading-text"><br />...loading</div>

        <!-- Step 2: Show Account Details -->
        <div
          v-if="(tokenId && isAuthenticated) || (tokenId === 0 && isAuthenticated)"
          class="nft-modal-card"
        >
          <div class="nft-banner-image">
            <div
              v-if="updateBannerShow"
              class="panel-upload--dropzone"
              :class="{ active: isDragged }"
              @dragenter="onDragEnterBanner"
              @dragleave="onDragLeaveBanner"
              @drop.prevent="onDropHandlerBanner($event)"
              @dragover.prevent
            >
              <input
                type="file"
                multiple
                ref="fileRefBanner"
                @change="onFileChangedHandlerBanner()"
              />
              <div class="dropzone-box" @click="openSelectFileBanner">
                <i-mdi-timer-sand v-if="isUploading" class="icon-color" />
                <i-mdi-upload v-else class="icon-color" />
                <span>Drop files here for upload to IPFS</span>
                <div class="dropzone-is-loading" :class="{ active: isUploading }">
                  <div class="dropzone-loading--bar"></div>
                </div>
                <span v-show="fileCountBannerImg > 0"
                  >{{ fileCountBannerImg - finished }} of {{ fileCountBannerImg }} files
                  uploaded</span
                >
                <div class="dropzone-details">
                  <div class="dropzone-detail">{{ result.count }} files</div>
                  <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
                </div>
              </div>
            </div>
            <img
              v-if="bannerImg"
              :src="`${getUrlProtocol(bannerImg)}`"
              :alt="`${name ? name : ''}`"
            />
            <button
              :class="
                bannerImg || updateBannerShow
                  ? 'nft-banner-image-edit-button'
                  : 'nft-banner-image-add-button'
              "
              @click="toggleBannerUpload()"
            >
              {{ updateBannerShow ? "hide" : "upload" }}
            </button>
          </div>
          <div class="nft-modal-card">
            <div class="row">
              <div class="nft-profile-image">
                <div
                  v-if="updateProfileShow"
                  class="panel-upload--dropzone"
                  :class="{ active: isDragged }"
                  @dragenter="onDragEnterProfile"
                  @dragleave="onDragLeaveProfile"
                  @drop.prevent="onDropHandlerProfile($event)"
                  @dragover.prevent
                >
                  <input
                    type="file"
                    multiple
                    ref="fileRefProfile"
                    @change="onFileChangedHandlerProfile()"
                  />
                  <div class="dropzone-box" @click="openSelectFileProfile">
                    <i-mdi-timer-sand v-if="isUploading" class="icon-color" />
                    <i-mdi-upload v-else class="icon-color" />
                    <span>Drop files here for upload to IPFS</span>
                    <div class="dropzone-is-loading" :class="{ active: isUploading }">
                      <div class="dropzone-loading--bar"></div>
                    </div>
                    <span v-show="fileCountProfileImg > 0"
                      >{{ fileCountProfileImg - finished }} of {{ fileCountProfileImg }} files
                      uploaded</span
                    >
                    <div class="dropzone-details">
                      <div class="dropzone-detail">{{ result.count }} files</div>
                      <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
                    </div>
                  </div>
                </div>
                <img
                  v-if="profileImg"
                  :src="`${getUrlProtocol(profileImg)}`"
                  :alt="`${name ? name : ''}`"
                />
                <img
                  v-if="!profileImg && !updateProfileShow"
                  src="../assets/images/ImageError.png"
                  alt="No image"
                />
                <button
                  :class="
                    profileImg || updateProfileShow
                      ? 'nft-profile-image-edit-button'
                      : 'nft-profile-image-add-button'
                  "
                  @click="toggleProfileUpload()"
                >
                  {{ updateProfileShow ? "hide" : "upload" }}
                </button>
              </div>
              <div class="column col-center">
                <div class="nft-form-container">
                  <div class="nft-modal-title">
                    <label>Name</label>
                    <div class="input-wrapper">
                      <input type="text" name="name" v-model="name" />
                      <button class="update-field-button" @click="updateName(name)">update</button>
                    </div>
                  </div>
                  <div class="nft-modal-address">
                    <label>Account Address</label>
                    <div class="input-wrapper">
                      <input type="text" name="address" v-model="accountAddress" />
                      <button class="update-field-button" @click="updateAddress(accountAddress)">
                        update
                      </button>
                    </div>
                  </div>
                  <div class="nft-modal-website">
                    <label>Website</label>
                    <div class="input-wrapper">
                      <input type="text" name="website" v-model="website" />
                      <button class="update-field-button" @click="updateWebsite(website)">
                        update
                      </button>
                    </div>
                  </div>
                  <div class="nft-modal-slogan">
                    <label>Slogan</label>
                    <div class="input-wrapper">
                      <input type="text" name="slogan" v-model="slogan" />
                      <button class="update-field-button" @click="updateSlogan(slogan)">
                        update
                      </button>
                    </div>
                  </div>
                  <div class="nft-modal-description">
                    <label>Description</label>
                    <div class="textarea-wrapper">
                      <textarea v-model="description" rows="5" cols="50"></textarea>
                      <button class="update-field-button" @click="updateDescription(description)">
                        update
                      </button>
                    </div>
                  </div>
                  <!-- Add Traits Form -->
                  <div v-if="!attributes" class="nft-modal-add-attribute">
                    <div class="nft-add-attribute">
                      <div class="nft-attribute-icon">
                        <label>Trait Icon</label>
                        <div class="input-wrapper">
                          <input type="text" name="traitIcon" v-model="traitIcon" />
                          <button class="update-field-button" @click="updateTraitIcon(traitIcon)">
                            update
                          </button>
                        </div>
                      </div>
                      <div class="nft-attribute-display-type">
                        <!-- TODO This need to be a select with options from opensea -->
                        <label>Trait Display Type</label>
                        <div class="input-wrapper">
                          <input type="text" name="traitDisplayType" v-model="traitDisplayType" />
                          <button
                            class="update-field-button"
                            @click="updateTraitDisplayType(traitDisplayType)"
                          >
                            update
                          </button>
                        </div>
                        <!-- TODO This need to be a select with options from opensea -->
                      </div>
                      <div class="nft-attribute-trait-type">
                        <label>Trait Type</label>
                        <div class="input-wrapper">
                          <input type="text" name="traitType" v-model="traitType" />
                          <button class="update-field-button" @click="updateTraitType(traitType)">
                            update
                          </button>
                        </div>
                      </div>
                      <div class="nft-attribute-value">
                        <label>Trait Value</label>
                        <div class="input-wrapper">
                          <input type="text" name="traitValue" v-model="traitValue" />
                          <button class="update-field-button" @click="updateTraitValue(traitValue)">
                            update
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="row">
              <div class="column col-right">
                <div class="nft-main-image">
                  <div
                    v-if="updateImageShow"
                    class="panel-upload--dropzone"
                    :class="{ active: isDragged }"
                    @dragenter="onDragEnterImage"
                    @dragleave="onDragLeaveImage"
                    @drop.prevent="onDropHandlerImage($event)"
                    @dragover.prevent
                  >
                    <input
                      type="file"
                      multiple
                      ref="fileRefImage"
                      @change="onFileChangedHandlerImage()"
                    />
                    <div class="dropzone-box" @click="openSelectFileImage">
                      <i-mdi-timer-sand v-if="isUploading" class="icon-color" />
                      <i-mdi-upload v-else class="icon-color" />
                      <span>Drop files here for upload to IPFS</span>
                      <div class="dropzone-is-loading" :class="{ active: isUploading }">
                        <div class="dropzone-loading--bar"></div>
                      </div>
                      <span v-show="fileCountImages > 0"
                        >{{ fileCountImages - finished }} of {{ fileCountImages }} files
                        uploaded</span
                      >
                      <div class="dropzone-details">
                        <div class="dropzone-detail">{{ result.count }} files</div>
                        <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
                      </div>
                    </div>
                  </div>
                  <div v-if="getUrlProtocol(imageUrl) === 'mp4'" class="nft-modal-video">
                    <video height="240" controls>
                      <source :src="imageUrl" type="video/mp4" />
                      Your browser does not support the video tag.
                    </video>
                    <button
                      :class="
                        updateImageShow
                          ? 'nft-modal-image-edit-button'
                          : 'nft-modal-image-add-button'
                      "
                      @click="toggleImageUpload()"
                    >
                      {{ updateImageShow ? "hide" : "upload" }}
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
                      :class="
                        updateImageShow
                          ? 'nft-modal-image-edit-button'
                          : 'nft-modal-image-add-button'
                      "
                      @click="toggleImageUpload()"
                    >
                      {{ updateImageShow ? "hide" : "upload" }}
                    </button>
                  </div>
                  <div v-else-if="imageUrl" class="nft-modal-image">
                    <img :src="`${getUrlProtocol(imageUrl)}`" :alt="`${name}`" />
                    <button
                      :class="
                        imageUrl ? 'nft-modal-image-edit-button' : 'nft-modal-image-add-button'
                      "
                      @click="toggleImageUpload()"
                    >
                      {{ updateImageShow ? "hide" : "upload" }}
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <!-- NFT Metadata Attributes -->
            <div v-if="attributes" class="nft-modal-edit-attributes">
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
                        {{ showTrait === attr.trait_id ? "done" : "edit" }}
                      </button>
                    </div>
                  </div>
                </div>
              </template>
              <template v-for="attr in attributes" :key="attr.trait_id">
                <div v-if="showTrait === attr.trait_id && attr.trait_value" class="nft-attribute">
                  Trait #{{ attr.trait_id }}
                  <div class="nft-attribute-icon">
                    <input type="text" name="traitIcon" v-model.lazy="attr.icon" />
                    <button class="update-field-button" @click="updateTraitIcon(attr)">
                      update
                    </button>
                  </div>
                  <div class="nft-attribute-display-type">
                    <!-- TODO This need to be a select with options from opensea -->
                    <input type="text" name="traitDisplayType" v-model.lazy="attr.display_type" />
                    <button class="update-field-button" @click="updateTraitDisplayType(attr)">
                      update
                    </button>
                    <!-- TODO This need to be a select with options from opensea -->
                  </div>
                  <div class="nft-attribute-trait-type">
                    <input type="text" name="traitType" v-model.lazy="attr.trait_type" />
                    <button class="update-field-button" @click="updateTraitType(attr)">
                      update
                    </button>
                  </div>
                  <div class="nft-attribute-value">
                    <input type="text" name="traitValue" v-model.lazy="attr.trait_value" />
                    <button class="update-field-button" @click="updateTraitValue(attr)">
                      update
                    </button>
                  </div>
                </div>
              </template>
            </div>
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

/* Import our diffeent Services */
import authNFT from "../services/authNFT.js";
import tablelandCRUD from "../services/tablelandCRUD.js";

/* Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";

/* Import Smart Contract ABI and Mojo Contract Address */
import contractAbi from "../../../artifacts/contracts/mojo_mc_ERC721.sol/MCNFT.json";
const mojoCreatorsContractAddress = "0x2c1B4950d62C522eE010158B56f9430ad0966060";

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
const { loading, minting, account, isAuthenticated, mojoMCNFTTokens } = storeToRefs(store);

/* File Uploader Refs */
const fileRef = ref(null);
const fileRefImage = ref(null);
const fileRefBanner = ref(null);
const fileRefProfile = ref(null);
const isDragged = ref(false);
const finished = ref(0);
const isUploading = ref(false);
const cid = ref("");

/* Mojo Creators NFT Form Metadata fields */
const contract = ref("");
const tokenId = ref("");
const name = ref("");
const description = ref("");
const imageUrl = ref("");
const slogan = ref("");
const accountAddress = ref("");
const website = ref("");
const profileImg = ref("");
const bannerImg = ref("");
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

const showNFTs = ref(true);
const updateImageShow = ref(false);
const updateBannerShow = ref(false);
const updateProfileShow = ref(false);

const mintNew = ref(false);

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
 * Toggle our upload inputs
 */
const toggleMintNew = () => {
  mintNew.value = !mintNew.value;
  cancelMint();
};
const toggleShowNFTs = () => {
  showNFTs.value = !showNFTs.value;
};
const toggleImageUpload = () => {
  updateImageShow.value = !updateImageShow.value;
};
const toggleBannerUpload = () => {
  updateBannerShow.value = !updateBannerShow.value;
};
const toggleProfileUpload = () => {
  updateProfileShow.value = !updateProfileShow.value;
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
  store.setAuthing(true);
  try {
    if (account.value) {
      /* Authenticate user */
      const authAccount = new authNFT();
      /* Is a Tableland Rig NFT holder */
      const rigRider = await authAccount.authTablelandContractAddress(account.value);

      console.log("Authed Tableland Rig Holder", rigRider);
      if (rigRider) {
        store.setIsRigHolder(rigRider);
      }
      /* Mojo Music NFT holder */
      const authed = await authAccount.authMojoCreatorAccountAddress(account.value);

      console.log("Authed Mojo Creator NFT Holder : ", authed);
      if (authed) {
        store.setIsAuthenticated(authed);
        /* Fetch our Mojo Creator NFTs */
        fetchMojoNFTs();
      }
      store.setAuthing(false);
    }
  } catch (error) {
    store.setAuthing(false);
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
      toggleMintNew();
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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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
        description.toString()
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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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
        accountAddress.value.toString()
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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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

      let tx = await contract.update_slogan(BigNumber.from(tokenId.value), slogan.toString());

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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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

          const profileImg = profile_img.toString();
          console.log("Profile Image :", profileImg);

          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_profile_img(
        BigNumber.from(tokenId.value),
        profileImg.value.toString()
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

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
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

          const bannerImg = banner_img.toString();
          console.log("Banner Image :", bannerImg);

          /* Stop loading */
          store.setLoading(false);
        }
      );

      let tx = await contract.update_banner_img(
        BigNumber.from(tokenId.value),
        bannerImg.value.toString()
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
const updateWebsite = async (sitename) => {
  console.log("Website : ", sitename);

  // if (!tokenId.value) {
  //   console.log(`Please enter a token id to continue!`);
  //   return;
  // }
  /* This is the attribute number in attribute_table, an NFT can have many attributes */
  if (!sitename) {
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
      contract.on(
        "websiteUpdated",
        (receiver, timestamp, metadata_table_id, sitename, token_id) => {
          console.log("Receiver :", receiver);

          updatedAt.value = moment.unix(timestamp).toString();
          console.log("Updated At :", traitUpdatedAt.value);

          const metadataTableId = metadata_table_id.toNumber();
          console.log("Metadata Table Id :", metadataTableId);

          const websiteNew = sitename.toString();
          console.log("Website :", websiteNew);

          const tokenId = token_id.toNumber();
          console.log("Token Id :", tokenId);

          /* Stop loading */
          store.setLoading(false);
        }
      );

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
  // if (!traitIcon.value) {
  //   console.log(`Please enter a trait icon to continue!`);
  //   return;
  // }
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
  fileRefImage.value = null;
  fileRefBanner.value = null;
  fileRefProfile.value = null;
  isDragged.value = false;
  finished.value = 0;
  isUploading.value = false;
  cid.value = "";
  audioVideoType.value = "";
  size.value = "";
  /* Reset our NFT Metadata Form Values */
  contract.value = "";
  tokenId.value = "";
  name.value = "";
  description.value = "";
  imageUrl.value = "";
  slogan.value = "";
  accountAddress.value = "";
  website.value = "";
  profileImg.value = "";
  bannerImg.value = "";
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

  /* Stop All Loaders */
  store.setLoading(false);
  store.setMinting(false);
};

/**
 * Drag n Drop File Manager NFT Mint
 */
const onDropHandler = ($event) => {
  console.log("onDropHandler event", $event);

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
 * Drag n Drop File Manager NFT
 */
const onDropHandlerImage = ($event) => {
  console.log("onDropHandlerImage event", $event);

  if (isUploading.value) return false;
  isDragged.value = false;
  fileRefImage.value.files = $event.dataTransfer.files;
  onFileChangedHandlerImage();
};
const openSelectFileImage = () => {
  if (isUploading.value) return false;
  fileRefImage.value.click();
};
const onDragEnterImage = () => {
  isDragged.value = true;
};
const onDragLeaveImage = () => {
  isDragged.value = false;
};

/**
 * Drag n Drop File Manager NFT Banner Image
 */
const onDropHandlerBanner = ($event) => {
  console.log("onDropHandlerBanner event", $event);

  if (isUploading.value) return false;
  isDragged.value = false;
  fileRefBanner.value.files = $event.dataTransfer.files;
  onFileChangedHandlerBanner();
};
const openSelectFileBanner = () => {
  if (isUploading.value) return false;
  fileRefBanner.value.click();
};
const onDragEnterBanner = () => {
  isDragged.value = true;
};
const onDragLeaveBanner = () => {
  isDragged.value = false;
};

/**
 * Drag n Drop File Manager NFT Profile
 */
const onDropHandlerProfile = ($event) => {
  console.log("onDropHandler event", $event);

  if (isUploading.value) return false;
  isDragged.value = false;
  fileRefProfile.value.files = $event.dataTransfer.files;
  onFileChangedHandlerProfile();
};
const openSelectFileProfile = () => {
  if (isUploading.value) return false;
  fileRefProfile.value.click();
};
const onDragEnterProfile = () => {
  isDragged.value = true;
};
const onDragLeaveProfile = () => {
  isDragged.value = false;
};

/**
 * @param {File} file
 * @returns {Object}
 */
const uploadFileHandler = async (file, type) => {
  store.setLoading(true);
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
  /* Generate and IPFS URI for NFT's */
  if (type === "nftImageUrl") {
    imageUrl.value = generateLink(uploadResult.data);
  } else if (type === "imageUrl") {
    imageUrl.value = generateLink(uploadResult.data);
    updateImage(imageUrl.value.toString());
  } else if (type === "bannerImg") {
    bannerImg.value = generateLink(uploadResult.data);
    updateBannerImg(bannerImg.value.toString());
    updateBannerShow.value = !updateBannerShow.value;
  } else if (type === "profileImg") {
    profileImg.value = generateLink(uploadResult.data);
    updateProfileImg(profileImg.value.toString());
    updateProfileShow.value = !updateProfileShow.value;
  }

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
  const files = store.filesNft.map((file) => uploadFileHandler(file, "nftImageUrl"));
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
    fileRef.value.files = null;
    fileRef.value.value = null;
  } catch (error) {
    finished.value = 0;
    isUploading.value = false;
  } finally {
    finished.value = 0;
    isUploading.value = false;
  }
};

/*
 * On file change will update our NFT Image
 */
const onFileChangedHandlerImage = async () => {
  isUploading.value = true;
  store.addImagesFiles(...fileRefImage.value.files);
  const files = store.imagesNft.map((file) => uploadFileHandler(file, "imageUrl"));
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
    store.addImagesFiles(...successfully.map(({ error, data: file }) => file));
    fileRefImage.value.files = null;
    fileRefImage.value.value = null;
  } catch (error) {
    finished.value = 0;
    isUploading.value = false;
  } finally {
    finished.value = 0;
    isUploading.value = false;
  }
};

/*
 * On file change will update our NFT Banner
 */
const onFileChangedHandlerBanner = async () => {
  isUploading.value = true;
  store.addBannerImgFiles(...fileRefBanner.value.files);
  const files = store.bannerImgNft.map((file) => uploadFileHandler(file, "bannerImg"));
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
    store.addBannerImgFiles(...successfully.map(({ error, data: file }) => file));
    fileRefBanner.value.files = null;
    fileRefBanner.value.value = null;
  } catch (error) {
    finished.value = 0;
    isUploading.value = false;
  } finally {
    finished.value = 0;
    isUploading.value = false;
  }
};

/*
 * On file change will update our NFT Profile
 */
const onFileChangedHandlerProfile = async () => {
  isUploading.value = true;
  store.addProfileImgFiles(...fileRefProfile.value.files);
  const files = store.profileImgNft.map((file) => uploadFileHandler(file, "profileImg"));
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
    store.addProfileImgFiles(...successfully.map(({ error, data: file }) => file));
    fileRefProfile.value.files = null;
    fileRefProfile.value.value = null;
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

const fileCountImages = computed(() => {
  return store.imagesNft.length;
});

const fileCountBannerImg = computed(() => {
  return store.bannerImgNft.length;
});

const fileCountProfileImg = computed(() => {
  return store.profileImgNft.length;
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

/**
 * Fetch Mojo Creator NFT
 */
async function loadMojoNFT(id) {
  store.setLoading(true);
  /* Load Tableland CRUD */
  const tableland = new tablelandCRUD();
  const mcNFT = await tableland.getMojoCreatorNFTsById(id);
  console.log("Mojo Creator NFT Data: ", mcNFT[0]);

  if (mcNFT[0]) {
    /* Mojo Creators NFT Form Metadata fields */
    tokenId.value = mcNFT[0][0] ? mcNFT[0][0] : 0;
    name.value = mcNFT[0][1] ? mcNFT[0][1] : "";
    description.value = mcNFT[0][2] ? mcNFT[0][2] : "";
    imageUrl.value = mcNFT[0][3] ? mcNFT[0][3] : "";
    accountAddress.value = mcNFT[0][4] ? mcNFT[0][4] : "";
    slogan.value = mcNFT[0][5] ? mcNFT[0][5] : "";
    profileImg.value = mcNFT[0][6] ? mcNFT[0][6] : "";
    bannerImg.value = mcNFT[0][7] ? mcNFT[0][7] : "";
    website.value = mcNFT[0][8] ? mcNFT[0][8] : "";

    /* Get our NFT metadata attributes */
    const mcNFTattributes = await tableland.getMojoCreatorNFTAttributes(id);
    /* Reset our Attributes for newly loaded NFT data */
    if (mcNFTattributes) attributes.value = [];
    mcNFTattributes.forEach((attribute) => {
      console.log("Mojo Creator NFT Attribute Data: ", attribute);
      let obj = {
        maintable_tokenid: attribute[0],
        trait_id: attribute[1],
        icon: attribute[2],
        display_type: attribute[3],
        trait_type: attribute[4],
        value: attribute[5],
      };
      attributes.value.push(...[obj]);
    });
    toggleShowNFTs();
    store.setLoading(false);
  }
}

/**
 * Fetch Mojo Creator NFT
 */
async function fetchMojoNFTs() {
  if (mojoMCNFTTokens.value.length === 0) {
    store.setLoading(true);
    try {
      const { ethereum } = window;
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const accountAddress = await signer.getAddress();

        if (accountAddress) {
          /* Load Api */
          const authAccount = new authNFT();
          /* Load Tableland CRUD */
          const tableland = new tablelandCRUD();
          /* Fetch NFTs by Wallet Account and Chain Id */
          let polygonTokens = await authAccount.fetchAccountNfts(80001, accountAddress);
          /* Filter by our Mojo Contract Address */
          const resultsMainnet = polygonTokens.filter((obj) => {
            return obj.contract.toLowerCase() === mojoCreatorsContractAddress.toLowerCase();
          });
          /* Load up our Token Data */
          resultsMainnet.forEach(async (nft) => {
            const mcNFT = await tableland.getMojoCreatorNFTsById(nft.tokenId);
            if (mcNFT[0]) {
              /* Mojo Creators NFT Form Metadata fields */
              let obj = {
                tokenId: mcNFT[0][0] ? mcNFT[0][0] : 0,
                name: mcNFT[0][1] ? mcNFT[0][1] : "",
                description: mcNFT[0][2] ? mcNFT[0][2] : "",
                image: mcNFT[0][3] ? mcNFT[0][3] : "",
                accountAddress: mcNFT[0][4] ? mcNFT[0][4] : "",
                slogan: mcNFT[0][5] ? mcNFT[0][5] : "",
                profileImg: mcNFT[0][6] ? mcNFT[0][6] : "",
                bannerImg: mcNFT[0][7] ? mcNFT[0][7] : "",
                website: mcNFT[0][8] ? mcNFT[0][8] : "",
              };

              /* Get our NFT metadata attributes */
              // const mcNFTattributes = tableland.getMojoCreatorNFTAttributes(nft.tokenId);
              /* Reset our Attributes for newly loaded NFT data */
              // if (mcNFTattributes) attributes.value = [];
              // mcNFTattributes.forEach((attribute) => {
              //   console.log(attribute);
              //   let obj = {
              //     maintable_tokenid: attribute[0],
              //     trait_id: attribute[1],
              //     icon: attribute[2],
              //     display_type: attribute[3],
              //     trait_type: attribute[4],
              //     value: attribute[5],
              //   };
              //   console.log("attributes.value BEFORE", attributes.value[0]);
              //   attributes.value.push(...[obj]);
              //   console.log("attributes.value AFTER", attributes.value[0]);
              // });
              store.addMojoMCNFTTokens(...[obj]);
              return;
            }
          });
        }
      }
      store.setLoading(false);
    } catch (error) {
      console.log("error", error);
      store.setLoading(false);
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
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#account {
  width: 100%;
  height: 100%;
  color: $black;
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
    height: inherit;
    display: flex;
    flex-direction: column;
    align-content: center;
    justify-content: flex-start;
    align-items: center;
    padding: 40px 0 40px 40px;

    @include breakpoint($break-md) {
      width: 96%;
      height: auto;
      padding: 2% 2% 0 2%;
    }

    @include breakpoint($break-sm) {
      width: 96%;
      height: auto;
      padding: 2% 2% 0 2%;
    }

    @include breakpoint($break-ssm) {
      width: 96%;
      height: auto;
      padding: 2% 2% 0 2%;
    }

    .account-connect-card {
      min-width: 260px;
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      align-items: center;
      align-content: center;
      background: #fff;
      border-radius: 1em;
      border: 0.5px solid #ffffff;
      box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
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
        box-shadow: 0 10px 30px -2px #e9e9e9;
        padding-left: 57px;
        padding-right: 57px;
        transition: 0.6s;
        cursor: pointer;

        &:hover {
          color: $black;
        }
      }
    }
  }
  .right {
    width: 100%;
    display: flex;
    flex-direction: column;
    align-content: center;
    justify-content: flex-start;
    align-items: flex-end;
    padding: 40px 40px 40px 20px;

    @include breakpoint($break-md) {
      width: 96%;
      height: auto;
      padding: 1% 2% 2% 2%;
    }

    @include breakpoint($break-sm) {
      width: 96%;
      height: auto;
      padding: 1% 2% 2% 2%;
    }

    @include breakpoint($break-ssm) {
      width: 96%;
      height: auto;
      padding: 1% 2% 2% 2%;
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
      border-radius: 1em;
      border: 0.5px solid #ffffff;
      box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
      padding: 0 0 20px 0;
      z-index: 999;

      @include breakpoint($break-md) {
        width: 100%;
      }
      @include breakpoint($break-sm) {
        width: 100%;
      }
      @include breakpoint($break-ssm) {
        width: 100%;
      }

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
        box-shadow: 0 10px 30px -2px #e9e9e9;
        padding-left: 57px;
        padding-right: 57px;
        transition: 0.6s;
        cursor: pointer;

        &:hover {
          color: $black;
        }
      }

      .control-panel {
        position: relative;
        width: 100%;
        height: 50px;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;

        .mint-new-button {
          position: absolute;
          top: 15px;
          left: 15px;
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
          transition: 0.6s;
          cursor: pointer;
          &:hover {
            color: $black;
          }
        }
        .nft-showcase-edit-button {
          position: absolute;
          top: 15px;
          right: 15px;
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
          transition: 0.6s;
          cursor: pointer;
          &:hover {
            color: $black;
          }
        }

        .nft-showcase-add-button {
          position: absolute;
          top: 15px;
          right: 15px;
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
          transition: 0.6s;
          cursor: pointer;
          &:hover {
            color: $black;
          }
        }

        .loading-text {
          color: $black;
          font-size: 18px;
          font-weight: 900;
          line-height: 20px;
          margin: 0 auto;
          text-align: center;
          transition: 0.6s;
        }
      }

      .row {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
      }

      .token-list {
        position: relative;
        width: 97%;
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
        align-content: center;
        justify-content: center;
        align-items: flex-start;
        margin: 0 auto;

        /* Tablet Landscape */
        @include breakpoint($break-md) {
          grid-template-columns: repeat(3, 1fr);
        }
        /* Tablet Portrait LG */
        @include breakpoint($break-sm) {
          grid-template-columns: repeat(2, 1fr);
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

        .nft {
          display: block;
          box-sizing: border-box;
          width: 100%;
          min-height: 240px;
          background: #f4f4f4;
          border-radius: 10px;
          overflow: hidden;
          cursor: pointer;

          .nft-video {
            width: 100%;
            margin: 0 auto;
            padding: 0;
            overflow: hidden;
            background: #f4f4f4;

            video {
              width: 100%;
              height: 100%;
              object-fit: contain;
              overflow: hidden;
            }
          }

          .nft-image {
            width: 100%;
            margin: 0 auto;
            padding: 0;
            overflow: hidden;

            img,
            svg {
              display: block;
              width: 100%;
              height: 100%;
              object-fit: contain;
              overflow: hidden;
            }
          }

          .nft-error-image {
            width: 100%;
            margin: 15px auto 0;
            padding: 0;
            overflow: hidden;

            img,
            svg {
              display: block;
              width: 100%;
              height: 100%;
              object-fit: contain;
              overflow: hidden;
            }
          }

          .nft-title {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-transform: uppercase;
            text-align: center;
            margin: 20px 0;
          }

          .nft-description {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-transform: uppercase;
            text-align: center;
            margin: 20px 0;
          }

          .nft-external-url {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-transform: uppercase;
            text-align: center;
            margin: 20px 0;
          }

          .nft-animation-url {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-transform: uppercase;
            text-align: center;
            margin: 20px 0;
          }
          .nft-attributes {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-align: center;
            margin: 10px auto 0;
            display: flex;
            flex-direction: row wrap;
            align-content: flex-start;
            justify-content: space-between;
            align-items: flex-start;
            overflow: scroll;

            .nft-attribute-card {
              width: auto;
              min-width: 60px;
              min-height: 40px;
              color: $black;
              background-color: #fff;
              border: 1px solid $mojo-blue;
              border-radius: 10px;
              letter-spacing: 1px;
              font-size: 12px;
              line-height: 20px;
              margin: 0 5px 5px 5px;
              padding: 10px;
              text-align: left;

              .nft-attribute-card-trait {
                display: flex;
                flex-direction: row wrap;
                align-content: flex-start;
                justify-content: space-between;
                align-items: flex-start;
              }
            }
          }
        }
      }

      .form-container {
        width: 360px;
        height: auto;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        padding: 20px 0 10px;

        h2 {
          color: $mojo-dark-blue;
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
            font-size: 1.3rem;
            line-height: 1.4rem;
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
          box-shadow: 0 10px 30px -2px #e9e9e9;
          border-radius: 40px;

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
            color: $black;
            background-color: #fdfdfd;
            border-radius: 40px;
            letter-spacing: 1px;
            font-size: 14px;
            margin-bottom: 10px;
            padding: 10px;
            text-align: center;

            @include breakpoint($break-md) {
              width: 80%;
            }
            @include breakpoint($break-ssm) {
              width: 80%;
            }
            @include breakpoint($break-ssm) {
              width: 80%;
            }

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
            transition: 0.6s;

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
          font-size: 18px;
          line-height: 24px;
          letter-spacing: 0.1em;
          margin: 0 0 2px 15px;
        }

        /*Clearing Floats*/
        .cf:before,
        .cf:after {
          content: "";
          display: table;
        }

        .cf:after {
          clear: both;
        }

        .cf {
          zoom: 1;
        }

        /* Form wrapper styling - https://codepen.io/NoorA1125/pen/movOEN */
        .input-wrapper {
          width: 360px;
          height: 40px;
          margin: 0 0 10px 0;
          border-radius: 40px;
          background: transparent;
          box-shadow: 0 10px 30px -2px #e9e9e9;
        }

        /* Form text input */
        .input-wrapper input {
          padding-left: 20px;
          width: 340px;
          height: 20px;
          padding: 10px 5px 10px 15px;
          float: left;
          border: 0;
          background: #fff;
          border-radius: 40px;
          border-top-style: none;
        }

        .input-wrapper input:focus {
          outline: 0;
          background: #fff;
        }

        .input-wrapper input::-webkit-input-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
          padding-left: 20px;
        }

        .input-wrapper input:-moz-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
        }

        .input-wrapper input:-ms-input-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
          border-style: none;
        }

        /* Update Field Button */
        .input-wrapper button {
          overflow: visible;
          position: relative;
          float: right;
          border: 0;
          padding: 0;
          height: 40px;
          width: 110px;
          color: #fff;
          text-transform: uppercase;
          background: $mojo-blue;
          border-radius: 40px;
          text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.3);
          transition: 0.6s;
          cursor: pointer;
        }

        .input-wrapper button:hover {
          background: $mojo-dark-blue;
        }

        .input-wrapper button:active,
        .input-wrapper button:focus {
          background: $mojo-dark-blue;
          outline: 0;
        }

        .input-wrapper button::-moz-focus-inner {
          /* remove extra button spacing for Mozilla Firefox */
          border: 0;
          padding: 0;
        }

        .textarea-wrapper {
          width: 360px;
          height: 100px;
          margin: 0 0 10px 0;
          border-radius: 30px;
          background: transparent;
          box-shadow: 0 10px 30px -2px #e9e9e9;
        }

        /* Form text input */
        .textarea-wrapper textarea {
          width: 330px;
          height: 70px;
          padding: 15px;
          float: left;
          border: 0;
          background: #fff;
          border-radius: 30px;
          border-top-style: none;
          resize: none;
        }

        .textarea-wrapper textarea:focus {
          outline: 0;
          background: #fff;
        }

        .textarea-wrapper textarea::-webkit-input-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
          padding-left: 20px;
        }

        .textarea-wrapper textarea:-moz-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
        }

        .textarea-wrapper textarea:-ms-input-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
          border-style: none;
        }

        /* Form submit button */
        .textarea-wrapper button {
          overflow: visible;
          position: relative;
          float: right;
          border: 0;
          padding: 0;
          height: 40px;
          width: 110px;
          color: #fff;
          text-transform: uppercase;
          background: $mojo-blue;
          border-radius: 40px;
          text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.3);
          margin-top: 15px;
          transition: 0.6s;
          cursor: pointer;
        }

        .textarea-wrapper button:hover {
          background: $mojo-dark-blue;
        }

        .textarea-wrapper button:active,
        .textarea-wrapper button:focus {
          background: $mojo-blue;
          outline: 0;
        }

        .textarea-wrapper button:focus:before,
        .textarea-wrapper button:active:before {
          border-right-color: #c42f2f;
        }

        .textarea-wrapper button::-moz-focus-inner {
          /* remove extra button spacing for Mozilla Firefox */
          border: 0;
          padding: 0;
        }

        .select-row {
          position: relative;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          align-items: left;
          margin-bottom: 15px;
        }

        .select-wrapper {
          width: 360px;
          height: 40px;
          margin: 0 0 10px 0;
          border-radius: 40px;
          background: transparent;
          box-shadow: 0 10px 30px -2px #e9e9e9;
        }

        /* Form text input */
        .select-wrapper select {
          width: 330px;
          height: 40px;
          padding: 10px 5px 10px 15px;
          float: left;
          border: 0;
          background: #fff;
          border-radius: 40px;
          border-top-style: none;
        }

        .select-wrapper select:focus {
          outline: 0;
          background: #fff;
        }

        .select-wrapper select::-webkit-input-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
          padding-left: 20px;
        }

        .select-wrapper select:-moz-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
        }

        .select-wrapper select:-ms-input-placeholder {
          color: #999;
          font-weight: normal;
          font-style: italic;
          border-style: none;
        }

        /* Update Field Button */
        .select-wrapper button {
          overflow: visible;
          position: relative;
          float: right;
          border: 0;
          padding: 0;
          height: 40px;
          width: 110px;
          color: #fff;
          text-transform: uppercase;
          background: $mojo-blue;
          border-radius: 40px;
          text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.3);
          transition: 0.6s;
          cursor: pointer;
        }

        .select-wrapper button:hover {
          background: $mojo-dark-blue;
        }

        .select-wrapper button:active,
        .select-wrapper button:focus {
          background: $mojo-dark-blue;
          outline: 0;
        }

        .select-wrapper button::-moz-focus-inner {
          /* remove extra button spacing for Mozilla Firefox */
          border: 0;
          padding: 0;
        }

        .update-field-button {
          overflow: visible;
          position: relative;
          float: right;
          border: 0;
          padding: 0;
          cursor: pointer;
          height: 40px;
          width: 110px;
          color: #fff;
          background: $mojo-blue;
          border-radius: 40px;
        }

        .update-field-button:hover {
          /*     background: #e54040; */
        }

        .update-field-button:active,
        .update-field-button:focus {
          background: $mojo-blue;
          outline: 0;
        }

        .update-field-button:focus:before,
        .update-field-button:active:before {
          border-right-color: #c42f2f;
        }

        .update-field-button::-moz-focus-inner {
          /* remove extra button spacing for Mozilla Firefox */
          border: 0;
          padding: 0;
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
            box-shadow: 0 10px 30px -2px #e9e9e9;
            padding-left: 20px;
            padding-right: 20px;
            border-radius: 10px;
            margin-left: 1%;
            cursor: pointer;
          }

          .mint-button {
            color: #fff;
            background-color: $mojo-green;
            font-size: 18px;
            font-weight: bold;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 57px;
            padding-right: 57px;
            margin: 10px 1% 10px 0;
            box-shadow: 0 10px 30px -2px #e9e9e9;
            transition: 0.6s;
            cursor: pointer;

            &:hover {
              color: $black;
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
            box-shadow: 0 10px 30px -2px #e9e9e9;
            transition: 0.6s;
            cursor: pointer;

            &:hover {
              color: $mojo-blue;
            }
          }

          .restart-button {
            color: $white;
            background-color: $mojo-dark-blue;
            font-size: 18px;
            font-weight: bold;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 40px;
            padding-right: 40px;
            margin: 10px 0 10px 1%;
            box-shadow: 0 10px 30px -2px #e9e9e9;
            transition: 0.6s;
            cursor: pointer;

            &:hover {
              color: $black;
            }
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
        margin: 2% 2% 20px;
        padding: 0;

        img,
        svg {
          display: block;
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
          transition: 0.6s;
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
          transition: 0.6s;
          cursor: pointer;
          &:hover {
            color: $black;
          }
        }

        .panel-upload--dropzone {
          width: 100%;
          min-height: 200px;
          position: relative;
          display: flex;
          align-content: center;
          align-items: center;
          justify-content: center;
          background-color: #fdfdfd;
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
            letter-spacing: 1px;
            font-size: 14px;
            padding: 10px;
            text-align: center;

            @include breakpoint($break-md) {
              width: 80%;
            }
            @include breakpoint($break-ssm) {
              width: 80%;
            }
            @include breakpoint($break-ssm) {
              width: 80%;
            }

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
            width: 260px;
            background: #f4f4f4;
            border: 1px solid #1a1a1a;
            box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
            border-radius: 10px;
            margin: 0 2%;
            overflow: hidden;
            img,
            svg {
              display: block;
              width: 100%;
              height: 100%;
              object-fit: contain;
              overflow: hidden;
              margin: 0;
            }

            .panel-upload--dropzone {
              width: 100%;
              min-height: 200px;
              position: relative;
              display: flex;
              align-content: center;
              align-items: center;
              justify-content: center;
              background-color: #fdfdfd;
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
                letter-spacing: 1px;
                font-size: 14px;
                padding: 10px;
                text-align: center;

                @include breakpoint($break-md) {
                  width: 80%;
                }
                @include breakpoint($break-ssm) {
                  width: 80%;
                }
                @include breakpoint($break-ssm) {
                  width: 80%;
                }

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
              transition: 0.6s;
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
              transition: 0.6s;
              cursor: pointer;
              &:hover {
                color: $black;
              }
            }
          }

          .col-left {
            flex-direction: column;
            align-content: flex-start;
            justify-content: flex-start;
            align-items: flex-start;
          }
          .col-center {
            flex-direction: column;
            align-content: flex-start;
            justify-content: flex-start;
            align-items: center;
          }

          .col-right {
            flex-direction: column;
            align-content: flex-start;
            justify-content: flex-start;
            align-items: flex-end;
          }

          .column {
            width: 100%;
            position: relative;
            display: flex;

            .nft-main-image {
              flex-direction: column;
              align-content: flex-start;
              justify-content: flex-start;
              align-items: center;
              margin: 20px 20px 0 0;
            }

            /*Clearing Floats*/
            .cf:before,
            .cf:after {
              content: "";
              display: table;
            }

            .cf:after {
              clear: both;
            }

            .cf {
              zoom: 1;
            }

            .panel-upload--dropzone {
              width: 100%;
              min-height: 200px;
              position: relative;
              display: flex;
              align-content: center;
              align-items: center;
              justify-content: center;
              background-color: #fdfdfd;
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
                letter-spacing: 1px;
                font-size: 14px;
                padding: 10px;
                text-align: center;

                @include breakpoint($break-md) {
                  width: 80%;
                }
                @include breakpoint($break-ssm) {
                  width: 80%;
                }
                @include breakpoint($break-ssm) {
                  width: 80%;
                }

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

            .nft-form-container {
              label {
                color: $mojo-blue;
                font-style: normal;
                font-weight: 800;
                font-size: 18px;
                line-height: 30px;
                letter-spacing: 0.1em;
                margin: 0 0 2px 15px;
              }
              /* Form wrapper styling - https://codepen.io/NoorA1125/pen/movOEN */
              .input-wrapper {
                width: 460px;
                height: 40px;
                margin: 0 0 10px 0;
                border-radius: 40px;
                background: transparent;
                box-shadow: 0 10px 30px -2px #e9e9e9;
              }

              /* Form text input */
              .input-wrapper input {
                padding-left: 20px;
                width: 320px;
                height: 20px;
                padding: 10px 5px 10px 15px;
                float: left;
                border: 0;
                background: #fff;
                border-radius: 40px;
                border-top-style: none;
              }

              .input-wrapper input:focus {
                outline: 0;
                background: #fff;
              }

              .input-wrapper input::-webkit-input-placeholder {
                color: #999;
                font-weight: normal;
                font-style: italic;
                padding-left: 20px;
              }

              .input-wrapper input:-moz-placeholder {
                color: #999;
                font-weight: normal;
                font-style: italic;
              }

              .input-wrapper input:-ms-input-placeholder {
                color: #999;
                font-weight: normal;
                font-style: italic;
                border-style: none;
              }

              /* Update Field Button */
              .input-wrapper button {
                overflow: visible;
                position: relative;
                float: right;
                border: 0;
                padding: 0;
                height: 40px;
                width: 110px;
                color: #fff;
                text-transform: uppercase;
                background: $mojo-blue;
                border-radius: 40px;
                text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.3);
                transition: 0.6s;
                cursor: pointer;
              }

              .input-wrapper button:hover {
                background: $mojo-dark-blue;
              }

              .input-wrapper button:active,
              .input-wrapper button:focus {
                background: $mojo-dark-blue;
                outline: 0;
              }

              .input-wrapper button::-moz-focus-inner {
                /* remove extra button spacing for Mozilla Firefox */
                border: 0;
                padding: 0;
              }

              .textarea-wrapper {
                width: 460px;
                height: 100px;
                margin: 0 0 10px 0;
                border-radius: 40px;
                background: transparent;
                box-shadow: 0 10px 30px -2px #e9e9e9;
              }

              /* Form text input */
              .textarea-wrapper textarea {
                padding-left: 20px;
                width: 430px;
                height: 79px;
                padding: 15px;
                float: left;
                border: 0;
                background: #fff;
                border-radius: 30px;
                border-top-style: none;
                resize: none;
              }

              .textarea-wrapper textarea:focus {
                outline: 0;
                background: #fff;
              }

              .textarea-wrapper textarea::-webkit-input-placeholder {
                color: #999;
                font-weight: normal;
                font-style: italic;
                padding-left: 20px;
              }

              .textarea-wrapper textarea:-moz-placeholder {
                color: #999;
                font-weight: normal;
                font-style: italic;
              }

              .textarea-wrapper textarea:-ms-input-placeholder {
                color: #999;
                font-weight: normal;
                font-style: italic;
                border-style: none;
              }

              /* Form submit button */
              .textarea-wrapper button {
                overflow: visible;
                position: relative;
                float: right;
                border: 0;
                padding: 0;
                height: 40px;
                width: 110px;
                color: #fff;
                text-transform: uppercase;
                background: $mojo-blue;
                border-radius: 40px;
                text-shadow: 0 -1px 0 rgba(0, 0, 0, 0.3);
                margin-top: 15px;
                transition: 0.6s;
                cursor: pointer;
              }

              .textarea-wrapper button:hover {
                background: $mojo-dark-blue;
              }

              .textarea-wrapper button:active,
              .textarea-wrapper button:focus {
                background: $mojo-blue;
                outline: 0;
              }

              .textarea-wrapper button:focus:before,
              .textarea-wrapper button:active:before {
                border-right-color: #c42f2f;
              }

              .textarea-wrapper button::-moz-focus-inner {
                /* remove extra button spacing for Mozilla Firefox */
                border: 0;
                padding: 0;
              }

              .nft-modal-title {
                width: 100%;
                margin: 0 0 10px 0;
              }
              .nft-modal-address {
                width: 100%;
                margin: 0 0 10px 0;
              }

              .nft-modal-website {
                width: 100%;
                margin: 0 0 10px 0;
              }

              .nft-modal-slogan {
                width: 100%;
                margin: 0 0 10px 0;
              }

              .nft-modal-description {
                width: 100%;
                margin: 0 0 10px 0;
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
                  border: 1px solid $mojo-blue;
                  outline: none;
                }
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
            transition: 0.6s;
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
            transition: 0.6s;
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
          margin: 0 auto 30px;
          padding: 0;
          overflow: hidden;
          box-sizing: border-box;
          background: #f4f4f4;
          border: 1px solid #1a1a1a;
          box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
          border-radius: 10px;

          img,
          svg {
            display: block;
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
            transition: 0.6s;
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
            transition: 0.6s;
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
            border: 1px solid $mojo-blue;
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
                  box-shadow: 0 10px 30px -2px #e9e9e9;
                  height: auto;
                  border: 0;
                  margin: 0 0 0 5px;
                  transition: 0.6s;
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
