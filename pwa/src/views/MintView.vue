<template>
  <section id="mint-content">
    <div class="main">
      <section id="mint">
        <h2>Mint an Audio/Media NFT</h2>
        <!-- Top Row -->
        <div class="row">
          <!-- Left Side -->
          <!-- MetaMask NOT Connected -->
          <div v-if="!account" class="left">
            <p class="connect-message">
              Connect your MetaMask and mint your Audio/Media NFT's for your followers and
              subscribers allowing them to unlock bonus content and earn additional rewards.
            </p>
          </div>
          <!-- END MetaMask NOT Connected -->
          <!-- MetaMask Connected -->
          <div v-if="account" class="left">
            <section v-if="!imageUrl && formTab === 'one'" id="panel-upload">
              <div class="content panel-upload--content">
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
                    <!-- Uploader Icon -->
                    <i-mdi-timer-sand v-if="isUploading" class="icon-color" />
                    <i-mdi-upload v-else class="icon-color" />
                    <!-- END Uploader Icon -->
                    <span>Drop files here or click to select files to upload to IPFS</span>
                    <div class="dropzone-is-loading" :class="{ active: isUploading }">
                      <div class="dropzone-loading--bar"></div>
                    </div>
                    <span v-show="fileCount > 0"
                      >{{ fileCount - finished }} of {{ fileCount }} files uploaded</span
                    >
                  </div>
                  <div class="dropzone-details">
                    <div class="dropzone-detail">{{ result.count }} files</div>
                    <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
                  </div>
                </div>
              </div>
            </section>
            <section v-if="imageUrl && formTab === 'one'" id="nft-modal">
              <!-- STEP 1 : Once user uploads an asset and the file is loaded onto IPFS, we can continue to add NFT data -->
              <div class="nft-modal-card">
                <div v-if="getUrlProtocol(imageUrl) === 'mp4'" class="nft-video">
                  <video width="320" height="240" controls>
                    <source :src="imageUrl" type="video/mp4" />
                    Your browser does not support the video tag.
                  </video>
                </div>
                <div v-if="getUrlProtocol(imageUrl) === 'mp3'" class="nft-video">
                  <audio ref="player" width="320" height="240">
                    <source :src="imageUrl" type="audio/mpeg" />
                  </audio>
                  <video width="320" height="240" controls>
                    <source :src="getUrlProtocol(imageUrl)" type="video/mp4" />
                    Your browser does not support the video tag.
                  </video>
                </div>
                <div v-else-if="imageUrl" class="nft-modal-image">
                  <img v-if="imageUrl" :src="`${getUrlProtocol(imageUrl)}`" :alt="`${name}`" />
                </div>
                <div class="nft-modal-title">
                  {{ name }}
                </div>
                <div class="nft-modal-description">
                  {{ description }}
                </div>
                <div class="nft-modal-external-url">
                  {{ externalUrl }}
                </div>
                <div class="nft-modal-description">
                  {{ animationUrl }}
                </div>
                <div class="nft-modal-description">
                  {{ youtubeUrl }}
                </div>
                <div v-show="attributes" class="nft-modal-edit-attributes">
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
                    <div
                      v-if="showTrait === attr.trait_id && attr.trait_value"
                      class="nft-attribute"
                    >
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
                <!-- STEP 2 : Show Add attribute form once NFT minted -->
                <div v-show="tokenId" class="nft-modal-add-attributes">
                  <div class="nft-attribute">
                    <div class="nft-attribute-icon">
                      <input
                        type="text"
                        name="traitIcon"
                        placeholder="enter an icon"
                        v-model="traitIcon"
                      />
                    </div>
                    <div class="nft-attribute-display-type">
                      <input
                        type="text"
                        name="traitDisplayType"
                        placeholder="enter a display type, eg. boost_number"
                        v-model="traitDisplayType"
                      />
                    </div>
                    <div class="nft-attribute-trait-type">
                      <input
                        type="text"
                        name="traitType"
                        placeholder="enter a trait type, eg. Stamina Increase"
                        v-model="traitType"
                      />
                    </div>
                    <div class="nft-attribute-value">
                      <input
                        type="text"
                        name="traitValue"
                        placeholder="enter a trait value, eg. 10"
                        v-model="traitValue"
                      />
                    </div>
                  </div>
                </div>
                <div class="nft-modal-approve">
                  <div v-show="tokenId" class="button-container">
                    <button class="add-button" @click="AddNewAttribute()">add new attribute</button>
                  </div>
                  <button
                    v-show="!tokenId"
                    :class="!approvedMint ? 'approve-button' : 'approved-button'"
                    @click="ConfirmApprovedMint(true)"
                  >
                    {{ !approvedMint ? "approve" : "let's mint" }}
                  </button>
                  <div v-show="!tokenId" class="file-image-link">
                    <a :href="imageUrl" title="Open in new tab" target="_blank"> ipfs </a>
                  </div>
                  <div v-show="tokenId" class="file-table-link">
                    <!-- <a
                  :href="`https://testnet.tableland.network/query?mode=list&s=SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27external_url%27%2Cexternal_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20Mint_TEA_80001_2644%20JOIN%20Mint_TEA_80001_2645%20ON%20Mint_TEA_80001_2644%2Etokenid%20%3D%20Mint_TEA_80001_2645%2Emaintable_tokenid%20WHERE%20tokenid%3D${tokenId}%20group%20by%20tokenid`"
                  title="View Tableland table"
                  target="_blank"
                >
                  tableland
                </a> -->
                    <!-- <a
                  :href="`https://testnet.tableland.network/query?mode=list&s=SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27external_url%27%2Cexternal_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20Mint_TEA_80001_2832%20JOIN%20Mint_TEA_80001_2833%20ON%20Mint_TEA_80001_2832%2Etokenid%20%3D%20Mint_TEA_80001_2833%2Emaintable_tokenid%20WHERE%20tokenid%3D${tokenId}%20group%20by%20tokenid`"
                  title="View Tableland data"
                  target="_blank"
                >
                  tableland
                </a> -->
                    <a
                      :href="`https://testnet.tableland.network/query?mode=list&s=SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27external_url%27%2Cexternal_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20Mint_TEA_137_41%20JOIN%20Mint_TEA_137_42%20ON%20Mint_TEA_137_41%2Etokenid%20%3D%20Mint_TEA_137_42%2Emaintable_tokenid%20WHERE%20tokenid%3D${tokenId}%20group%20by%20tokenid`"
                      title="View Tableland data"
                      target="_blank"
                    >
                      tableland
                    </a>
                  </div>
                  <button v-show="!tokenId" class="cancel-button" @click="cancelMint()">
                    cancel
                  </button>
                  <button v-show="tokenId" class="cancel-button" @click="cancelMint()">
                    reset
                  </button>
                </div>
              </div>
            </section>
          </div>
          <!-- END MetaMask Connected -->
          <!-- END Left Side -->

          <!-- ------------------------------------------------------------------------------------- -->

          <!-- Right Side -->

          <!-- MetaMask NOT Connected -->
          <div v-if="!account" class="right">
            <ConnectWalletButton v-model="account" v-if="!account" btnSize="large" />
          </div>
          <!-- END MetaMask NOT Connected -->

          <!-- MetaMask Connected -->
          <div v-if="account" class="right">
            <!-- Tab One Main NFT Metadata -->
            <div v-if="formTab === 'one'" id="form-tab-one" class="form-container">
              <h2>1. Mint NFT</h2>

              <!-- Data we receive after file upload HIDDEN -->
              <div class="input-row hidden">
                <input type="text" placeholder="Content ID" v-model="cid" />
              </div>
              <div class="input-row">
                <input
                  type="text"
                  placeholder="Audio/Video Type"
                  v-model="audioVideoType"
                  readonly
                />
              </div>
              <div class="input-row">
                <input type="text" placeholder="File Size" v-model="size" readonly />
              </div>
              <!-- Data we receive after mint HIDDEN -->
              <div class="input-row">
                <input type="text" placeholder="Token ID" v-model="tokenId" />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Created" v-model="createdAt" readonly />
              </div>

              <div class="input-row">
                <input type="text" placeholder="Name" v-model="name" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Enter a description" v-model="description" />
              </div>
              <div class="select-row">
                <select v-model="category">
                  <option value="" class="grey">Select a Category</option>
                  <option v-for="cat in categories" :key="cat.id" :value="cat.value">
                    {{ cat.label }}
                  </option>
                </select>
              </div>
              <div class="input-row">
                <input type="text" placeholder="Image Url" v-model="imageUrl" readonly />
              </div>

              <!-- Button Row -->
              <div v-if="account && formTab === 'one'" class="button-container">
                <button
                  v-if="!tokenId"
                  class="mint-button"
                  :disabled="!name || !description || !imageUrl || minting || !approvedMint"
                  @click="mintNFT()"
                >
                  {{ minting ? "minting" : "mint" }}
                </button>
                <button v-if="tokenId" class="mint-done-button" @click="switchToTab('two')">
                  next
                </button>
                <button class="restart-button" @click="cancelMint()">cancel</button>
              </div>
              <!-- END Button Row -->
            </div>
            <!-- END Mint Form -->

            <!-- Show loading if we uploading a file or minting, etc. -->
            <div v-show="loading || minting || tokenId" class="loading-message">
              <div v-show="loading" class="loading">loading, please wait...</div>
              <div v-show="minting" class="loading">minting NFT, please wait...</div>
              <div v-if="!loading && !minting && tokenId" class="loading">
                NFT brewed successfully...you can now add your additonal attributes
              </div>
            </div>
            <!-- END Tab One Main NFT Metadata -->

            <!-- Tab Two NFT Metadata Attributes -->
            <div v-if="formTab === 'two'" id="form-tab-two" class="form-container">
              <h2>2. Add Details</h2>
              <div class="input-row">
                <input type="text" placeholder="Title" v-model="title" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Website" v-model="website" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="License" v-model="license" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Royalty Fee" v-model="royaltyPercentage" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Price in ETH" v-model="price" />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Max invocations" v-model="maxInvocations" />
              </div>

              <!-- Button Row -->
              <div v-if="account && formTab === 'two'" class="button-container">
                <button class="back-button-blue" @click="switchToTab('one')">🔙</button>
                <button class="attr-button" @click="switchToTab('three')">Add Media</button>
              </div>
              <!-- END Button Row -->
            </div>
            <!-- END Tab Two NFT Metadata Attributes -->

            <!-- Tab Three NFT Pricing -->
            <div v-if="formTab === 'three'" id="form-tab-three" class="form-container">
              <h2>3. Add Media</h2>
              <div class="input-row">
                <textarea
                  v-model="longDescription"
                  placeholder="Add a full description here..."
                  rows="4"
                  cols="50"
                ></textarea>
              </div>
              <div class="input-row">
                <input type="text" placeholder="Preview Link" v-model="preview" />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Audio/Video Link" v-model="audioVideoURL" />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Add an external link" v-model="externalUrl" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Animation Link" v-model="animationURL" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Youtube Link" v-model="youtubeURL" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Resolution" v-model="resolution" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Duration" v-model="duration" />
              </div>
              <!-- Button Row -->
              <div v-if="account && formTab === 'three'" class="button-container">
                <button class="back-button-purple" @click="switchToTab('two')">🔙</button>
                <button class="update-button" @click="createNFTRow()">finish</button>
              </div>
              <!-- END Button Row -->
            </div>
          </div>
          <!-- END MetaMask Connected -->
          <!-- END Right Side */ -->
        </div>
        <!-- END Top Row -->
      </section>
    </div>
  </section>
</template>
<script>
import { ref, computed, onMounted } from "vue";
import { ethers, BigNumber } from "ethers";
// import { BigNumber } from "bignumber.js";
import moment from "moment";
import { Notyf } from "notyf";

/* Import our Pinia Store & Refs */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Import our IPFS and NftStorage Services */
import { uploadBlob } from "../services/ipfs.js";
import { fileSize, generateLink } from "../services/helpers";
// import { nftStorage } from "../services/nftStorage.js";
import authNFT from "../services/authNFT.js";
import alchemyApi from "../services/alchemyApi.js";
import JSConfetti from "js-confetti";

/* Import Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";
import ArrowBack from "../assets/svgs/ArrowBack.vue";

/* Import Smart Contract ABI and Mojo Contract Address */
import contractAbi from "../../../artifacts/contracts/mojo_ERC721.sol/MOJO.json";
const contractAddress = "0x6b9482bD2EEd7814EE5a88Cc93f687a3961D27Fb";

/* Console log with some style */
const stylesContract = ["color: black", "background: #e9429b"].join(";");
console.log("%c🎧 Mojo Contract Address %s ", stylesContract, contractAddress);
const stylesAbi = ["color: black", "background: cyan"].join(";");
console.log("%c🧭 Contract ABI Source %s 🧭", stylesAbi, contractAbi.sourceName);

/* LFG */
export default {
  name: "MintView",
  components: [ConnectWalletButton, ArrowBack],
  setup() {
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
    /* Init Pinia Store Values and Methods */
    const store = useStore();
    const {
      loading,
      minting,
      account,
      ethereumTokens,
      polygonTokens,
      optimismTokens,
      arbitrumTokens,
    } = storeToRefs(store);

    /* Set Form Tab */
    const formTab = ref("one");

    /* File Uploader Refs */
    const fileRef = ref(null);
    const isDragged = ref(false);
    const finished = ref(0);
    const isUploading = ref(false);

    /* NFT Form Metadata fields */
    const tokenId = ref("");
    const rowId = ref("");
    const cid = ref("");

    /* Visible on form, above hidden on form */
    const name = ref("");
    const description = ref("");
    const imageUrl = ref(null);
    const category = ref("");

    /* Calculated on Mint and IPFS upload */
    const size = ref("");
    const createdAt = ref("");

    /* NFT Form Metadata Attributes */
    const attributes = ref([]);
    const audioVideoType = ref("");
    const maxInvocations = ref(null);
    const royaltyPercentage = ref(null);
    const price = ref(null);
    const title = ref("");
    const license = ref("");
    const website = ref("");
    const longDescription = ref("");
    const preview = ref("");
    const externalUrl = ref("");
    const animationUrl = ref("");
    const youtubeUrl = ref("");
    const audioVideoURL = ref("");
    const animationURL = ref("");
    const youtubeURL = ref("");
    const resolution = ref("");
    const duration = ref("");

    /* Updating Traits Form
     * Traits start at 0 on mint, the date of mint is the first trait added
     */
    const showTrait = ref(1);
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

    /* Track Player */
    const categories = ref([
      { id: 1, label: "Fresh Jams", value: "Fresh Jams" },
      { id: 2, label: "Dance & Electronica", value: "Dance & Electronica" },
      { id: 3, label: "Pop", value: "Pop" },
      { id: 4, label: "Jazz & Classical", value: "Jazz & Classical" },
      { id: 5, label: "World & Ethnic", value: "World & Ethnic" },
      { id: 6, label: "Cinematic & Soundscapes", value: "Cinematic & Soundscapes" },
      { id: 7, label: "More", value: "More" },
    ]);

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
    const checkIfWalletIsConnected = async () => {
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
        const accounts = await ethereum.request({ method: "eth_accounts" });
        /* Update our Current Account in the Store */
        if (accounts.length !== 0) store.updateAccount(accounts[0]);
      } catch (error) {
        console.log(error);
      }
    };

    /* Connect Wallet */
    const connectWallet = async () => {
      const { ethereum } = window;
      try {
        if (!ethereum) {
          alert("Please connect 🦊 Metamask to continue!");
          return;
        }
        const [accountAddress] = await ethereum.request({
          method: "eth_requestAccounts",
        });
        console.log("Account Address", accountAddress);
        if (accountAddress) {
          store.updateAccount(accountAddress);
        }
      } catch (error) {
        console.log("Error", error);
      }
    };

    /**
     * Get our current 🦊 Metamask Account
     */
    const getAccount = async () => {
      try {
        const { ethereum } = window;
        if (!ethereum) return;
        /* Get our Account Details */
        const accounts = await ethereum.request({ method: "eth_accounts" });
        if (accounts.length !== 0) {
          store.updateAccount(accounts[0]);

          const stylesAccounts = ["color: black", "background: cyan"].join(";");
          console.log("%c🧰 Web3 Account %s ", stylesAccounts, account.value);
        } else {
          console.log("No authorized MetaMask accounts connected!");
        }
      } catch (error) {
        console.log(error);
      }
    };

    /* Fetch NFT by Account Address */
    const fetchTokens = async () => {
      if (account.value) {
        try {
          /* Infura API */
          const authAccount = new authNFT();
          /* Ethereum */
          if (ethereumTokens.value.length === 0) {
            let ethereumTokens = await authAccount.fetchAccountNfts(1, account.value);
            store.addEthereumTokens(...ethereumTokens);
          }
          /* Polygon */
          if (polygonTokens.value.length === 0) {
            let polygonTokens = await authAccount.fetchAccountNfts(137, account.value);
            store.addPolygonTokens(...polygonTokens);
          }

          /* We use Alchemy API for these */
          const authAlchemyAccount = new alchemyApi();
          /* Optimism */
          if (optimismTokens.value.length === 0) {
            let optimismTokens = await authAlchemyAccount.fetchAccountNfts(10, account.value);
            store.addOptimismTokens(...optimismTokens);
          }
          /* Arbitrum */
          if (arbitrumTokens.value.length === 0) {
            let arbitrumTokens = await authAlchemyAccount.fetchAccountNfts(42161, account.value);
            store.addArbitrumTokens(...arbitrumTokens);
          }
          /* Avalanche */
          // if (avalancheTokens.value.length === 0) {
          //   let avalancheTokens = await authAccount.fetchAccountNfts(
          //     42161,
          //     account.value
          //   );
          //   store.addAvalancheTokens(...avalancheTokens);
          //   let avalancheTestnetTokens = await authAccount.fetchAccountNfts(
          //     42161,
          //     account.value
          //   );
          //   store.addAvalancheTokens(...avalancheTestnetTokens);
          // }
        } catch (error) {
          console.log(`Error fetching tokens, please refresh to try again!`);
        }
      }
    };

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
        switchToTab("one");
        return;
      }
      if (name.value.length < 3) {
        notyf.error(`Name must be longer then 3 characters!`);
        switchToTab("one");
        return;
      }
      if (!imageUrl.value) {
        notyf.error(`Please upload an image to continue!`);
        switchToTab("one");
        return;
      }
      if (imageUrl.value.length < 10) {
        notyf.error(`Please upload a valid image to continue!`);
        switchToTab("one");
        return;
      }
      if (!category.value) {
        notyf.error(`Please upload an image to continue!`);
        switchToTab("one");
        return;
      }
      if (category.value.length < 10) {
        notyf.error(`Please select a category to continue!`);
        switchToTab("one");
        return;
      }
      /**
       * Some very basic form validation on a required description field
       */
      if (!description.value) {
        notyf.error(`Please enter a description to continue!`);
        switchToTab("one");
        return;
      }
      if (description.value.length < 10) {
        notyf.error(`Description must be longer then 10 characters!`);
        switchToTab("one");
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
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);

          /* Console log with some style */
          const styles = ["color: black", "background: #2bb5f0"].join(";");
          console.log("%c🎧 Mojo Contract Address:  %s 🎧", styles, contractAddress);

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

          /* Store NFT Metadata on NFT.Storage */
          // const nftStorageTMetadataURI = await nftStorage(
          //   name.value,
          //   description.value,
          //   imageUrl.value,
          //   size.value,
          //   createdAt.value,
          //   audioVideoType.value,
          //   title.value,
          //   category.value,
          //   license.value,
          //   website.value,
          //   longDescription.value,
          //   preview.value,
          //   audioVideoURL.value,
          //   animationURL.value,
          //   youtubeURL.value,
          //   resolution.value,
          //   duration.value
          // );
          /* Console log with some style */
          // const stylesNFTStorage = ["color: black", "background: #f23f3f"].join(";");
          // console.log(
          //   "%c💾 NFT.Storage ipfs:// link :  %s 💾",
          //   stylesNFTStorage,
          //   nftStorageTMetadataURI
          // );

          /* Check our Transaction results */
          // if (!nftStorageTMetadataURI) return;

          const mintDate = new Date();
          const mintDateTimestamp = mintDate.getTime();
          const mintDateString = mintDateTimestamp.toString();
          console.log("Mint Date String :", mintDateString);

          /* Mint our NFT using complex Struct */
          let nftTxn = await contract.safeMint(
            signer.getAddress(),
            name.value,
            description.value,
            imageUrl.value,
            category.value,
            "https://cloudflare-ipfs.com/ipfs/bafkreibx3akdct6syqhkis3dqsnekukhh5ib5pdwepfki7hf45viv4ylp4",
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
          console.log("%c💎 We just mined some beats on blocks! %s ", stylesReceipt, nftTxn.hash);

          /* Check our Transaction results */
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            /* Console log with some style */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c🧬 NFT Minted on Polygon, see transaction: https://mumbai.polygonscan.com/tx/${nftTxn.hash} %s`,
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

          /* Set to NFT Main Attributes Tab */
          switchToTab("two");

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
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);

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
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);
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
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);
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
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);
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
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);

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
     * Set our NFT External Url field via contract
     */
    const setExternalUrl = async (tokenId) => {
      if (!tokenId.value) {
        notyf.error(`We need a Token Id to continue!`);
        return;
      }
      /**
       * Some very basic form validation, these are loaded after IPFS upload
       * but users can edit so we still need some validation in UI
       */
      if (!externalUrl.value) {
        notyf.error(`Please enter an external url to continue!`);
        formTab.value = "one";
        return;
      }
      if (externalUrl.value.length < 3) {
        notyf.error(`NFT external url must be longer then 3 characters!`);
        formTab.value = "one";
        return;
      }
      /* Init loading indicator */
      const loadingIndicator = notyf.open({
        type: "loading",
        message: "⏳ Please wait while we add your NFT metadata attributes.",
      });
      /**
       * Set our NFT External Url via Contract method
       * @dev Not sure about this yet but leaves us a few options
       */
      try {
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();

          /**
           *  @dev Note: Reset this once Contracts deployed or re-dployed
           */
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);
          console.log("Talk to the wallet and pay gas fees", signer);

          /**
           *  Receive Emitted Event from Contract
           *  @dev See NewNftMinted emitted from our smart contract safeMint function
           */
          contract.on(
            "externalUrlUpdated",
            (receiver, timestamp, metadataTableId, external_url, tokenId) => {
              console.log("receiver ", receiver);

              console.log("timestamp ", timestamp);
              createdAt.value = moment.unix(timestamp).toString();
              console.log("createdAt.value ", createdAt.value);

              let tokenIdBigNo = new BigNumber(tokenId);
              console.log("tokenId ", tokenIdBigNo);
              rowId.value = tokenIdBigNo.toNumber();
              console.log("rowId.value ", rowId.value);

              console.log("metadataTableId ", metadataTableId);
              console.log("external_url ", external_url);
            }
          );

          let nftTxn = await contract.update_external_url(
            `https://testnets.opensea.io/assets/mumbai/${contractAddress}/${tokenId}`
          );

          /* Console log with some style */
          const stylesUpdate = ["color: black", "background: yellow"].join(";");
          console.log("%c⏳ Updating NFT ...please wait! %s", stylesUpdate, nftTxn.hash);

          // The OpenZeppelin base ERC721 contract emits a Transfer event
          // when a token is issued. tx.wait() will wait until a block containing
          // our transaction has been mined and confirmed. The transaction receipt
          // contains events emitted while processing the transaction.
          /* Console log with some style */

          const stylesMining = ["color: black", "background: yellow"].join(";");
          console.log("%c⛏ Mining...please wait! ⛏ %s", stylesMining, nftTxn.hash);
          const receipt = await nftTxn.wait();

          /* Console log with some style */
          const stylesReceipt = ["color: black", "background: purple"].join(";");
          console.log("%c💎 Congrats on enpowering your gem! 💎 %s", stylesReceipt, nftTxn.hash);

          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c🔧 NFT external url updated via Tableland contract, see transaction: https://mumbai.polygonscan.com/tx/${nftTxn.hash} %s`,
              stylesPolygon,
              nftTxn.hash
            );
            /* Remove loading indicator and show success notification */
            notyf.dismiss(loadingIndicator);
            notyf.success(
              `🧬 NFT table row been updated, see transaction: https://mumbai.polygonscan.com/tx/${nftTxn.hash}`
            );
            /* Set to NFT Add Media Tab */
            switchToTab("two");
            return;
          }
          notyf.error("Error updating NFT metadata!");
          return;
        } else {
          notyf.dismiss(loadingIndicator);
          notyf.error("Ethereum object doesn't exist!");
        }
      } catch (error) {
        notyf.dismiss(loadingIndicator);
        console.log("error", error);
      }
    };

    /**
     * Update our NFT metadata
     */
    const createNFTRow = async () => {
      if (!tokenId.value) {
        notyf.error(`We need a Token Id to continue!`);
        return;
      }
      /**
       * Some very basic form validation, these are loaded after IPFS upload
       * but users can edit so we still need some validation in UI
       */
      if (!name.value) {
        notyf.error(`Please enter a name to continue!`);
        formTab.value = "one";
        return;
      }
      if (name.value.length < 3) {
        notyf.error(`NFT name must be longer then 3 characters!`);
        formTab.value = "one";
        return;
      }
      if (!imageUrl.value) {
        notyf.error(`Please enter a imageUrl to continue!`);
        formTab.value = "one";
        return;
      }
      if (imageUrl.value.length < 10) {
        notyf.error(`NFT image Url must be longer then 10 characters!`);
        formTab.value = "one";
        return;
      }
      /**
       * Some very basic form validation on a required description field
       */
      if (!description.value) {
        notyf.error(`Please enter a description to continue!`);
        formTab.value = "one";
        return;
      }
      if (description.value.length < 10) {
        notyf.error(`NFT description must be longer then 10 characters!`);
        formTab.value = "one";
        return;
      }
      /* Init loading indicator */
      const loadingIndicator = notyf.open({
        type: "loading",
        message: "⏳ Please wait while we update your NFT metadata.",
      });

      const createdRowId = await store.createRow(
        tokenId.value,
        cid.value,
        name.value,
        description.value,
        externalUrl.value,
        animationUrl.value,
        youtubeUrl.value,
        imageUrl.value,
        size.value,
        createdAt.value,
        audioVideoType.value,
        maxInvocations.value,
        royaltyPercentage.value,
        price.value,
        title.value,
        category.value,
        license.value,
        website.value,
        longDescription.value,
        preview.value,
        audioVideoURL.value,
        animationURL.value,
        youtubeURL.value,
        resolution.value,
        duration.value
      );
      if (createdRowId) {
        /* Console log with some style */
        const stylesRowEntry = ["color: white", "background: #32c33a"].join(";");
        console.log(`%c💾 NFT metadata row created ID : %s`, stylesRowEntry, createdRowId);
        /* Remove loading indicator and show success notification */
        notyf.dismiss(loadingIndicator);
        notyf.open({
          type: "success",
          message: `💾 NFT with metadata created ID: ${createdRowId}`,
        });

        /* Set to NFT Main Attributes Tab */
        switchToTab("three");
        return;
      }
      notyf.dismiss(loadingIndicator);
      notyf.error(`Error adding a new table row, please try again!`);
      switchToTab("two");
      return;
    };

    /**
     * Cancel NFT Mint
     */
    const cancelMint = () => {
      /* Reset our NFT Metadata Form Values */
      tokenId.value = "";
      rowId.value = "";
      cid.value = "";
      fileRef.value = null;
      name.value = "";
      description.value = "";
      externalUrl.value = "";
      animationUrl.value = "";
      youtubeUrl.value = "";
      imageUrl.value = "";
      maxInvocations.value = null;
      royaltyPercentage.value = null;
      price.value = null;
      title.value = "";
      category.value = "";
      license.value = "";
      website.value = "";
      longDescription.value = "";
      preview.value = "";
      audioVideoType.value = "";
      audioVideoURL.value = "";
      animationURL.value = "";
      youtubeURL.value = "";
      resolution.value = "";
      duration.value = "";
      size.value = "";
      createdAt.value = "";
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
     * Approve Tableland NFT Mint
     */
    const ConfirmApprovedMint = (value) => {
      approvedMint.value = value;
    };

    /**
     * Switch Tab
     */
    const switchToTab = (value) => {
      formTab.value = value;
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
        console.log(`Oops! an error while processing your files.`, error.message);
        finished.value = 0;
        isUploading.value = false;
      } finally {
        console.log("finally");
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

    onMounted(async () => {
      /* Set scrollto func */
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: "smooth",
      });
      /* First check our account */
      await getAccount();
      await checkIfWalletIsConnected();
      await fetchTokens();
    });

    return {
      loading,
      minting,
      isUploading,
      finished,
      fileRef,
      fileCount,
      result,
      isDragged,
      account,
      formTab,
      tokenId,
      cid,
      name,
      description,
      externalUrl,
      animationUrl,
      youtubeUrl,
      imageUrl,
      maxInvocations,
      royaltyPercentage,
      price,
      attributes,
      traitIcon,
      traitDisplayType,
      traitType,
      traitValue,
      title,
      category,
      license,
      website,
      longDescription,
      preview,
      audioVideoType,
      audioVideoURL,
      animationURL,
      youtubeURL,
      resolution,
      duration,
      categories,
      size,
      createdAt,
      approvedMint,
      cancelMint,
      ConfirmApprovedMint,
      switchToTab,
      mintNFT,
      AddNewAttribute,
      editTrait,
      updateTraitIcon,
      updateTraitDisplayType,
      updateTraitType,
      updateTraitValue,
      setExternalUrl,
      createNFTRow,
      generateLink,
      fileSize,
      onDragEnter,
      onDragLeave,
      onDropHandler,
      openSelectFile,
      onFileChangedHandler,
      getUrlProtocol,
      checkIfWalletIsConnected,
      connectWallet,
      getAccount,
      jsConfettiSuccess,
    };
  },
};
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#mint-content {
  display: flex;
  flex-direction: column;
  align-content: center;
  justify-content: center;
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

    section#mint {
      height: 100%;
      color: #1a1a1a;
      background: $white;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 10px;
      overflow: scroll;

      @include breakpoint($medium) {
        padding: 0 60px 20px;
      }

      .row {
        display: flex;
        flex-direction: row;
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

      .left {
        width: 45%;
        height: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: flex-end;

        @include breakpoint($breakpoint-md) {
          width: 100%;
        }

        @include breakpoint($breakpoint-sm) {
          width: 100%;
        }

        .connect-message {
          max-width: 440px;
        }

        section#panel-upload {
          background-color: var(--gradient-100);
          border-top-left-radius: 1rem;
          border-bottom-left-radius: 1rem;
          border-top-right-radius: 0;

          width: 100%;
          height: 100%;

          @include breakpoint($medium) {
            margin-top: 0;
            padding-top: 0;
            border-top-left-radius: 1rem;
            border-top-right-radius: 1rem;
            border-bottom-left-radius: 0;
          }

          .panel-upload--content,
          .panel-upload--content .panel-upload--dropzone {
            width: 100%;
            height: 100%;
          }

          .panel-upload--dropzone {
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
              width: 80%;
              display: flex;
              flex-direction: column;
              align-items: center;
              padding: 0.8rem;
              border-radius: 0.5rem;
              text-align: center;

              svg {
                height: 48px;
                width: 48px;
                margin-bottom: 1rem;
              }

              span {
                color: #1a1a1a;
                font-size: 0.8rem;
              }
            }

            .dropzone-details {
              color: #1a1a1a;
              position: absolute;
              display: flex;
              bottom: 1rem;
              left: 1rem;

              .dropzone-detail {
                color: #1a1a1a;
                font-size: 0.8rem;
                background-color: var(--gradient-300);
                border-radius: 1rem;
                padding: 0.4rem 0.8rem;
                margin-right: 0.6rem;
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
              margin: 1rem 0 1rem 0;
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
          }
        }
        section#nft-modal {
          background-color: var(--gradient-100);
          border-top-right-radius: 1rem;
          border-bottom-right-radius: 0;
          border-bottom-left-radius: 0;
          border-top-right-radius: 1rem;
          width: 100%;
          height: 100%;

          @include breakpoint($medium) {
            margin-top: 0;
            padding-top: 0;
            border-top-left-radius: 1rem;
            border-top-right-radius: 1rem;
            border-bottom-left-radius: 0;
          }

          min-height: 720px;
          color: $black;
          display: flex;
          flex-direction: column;
          justify-content: flex-start;
          align-content: flex-start;
          align-items: center;

          padding: 0;

          @include breakpoint($breakpoint-md) {
            padding: 20px 0;
          }

          @include breakpoint($breakpoint-sm) {
            padding: 20px 0;
          }

          @include breakpoint($breakpoint-xs) {
            padding: 20px 0;
          }

          .nft-modal-loading {
            width: 600px;
            height: 100%;
            min-height: 720px;
            display: flex;
            flex-direction: column;
            align-content: center;
            justify-content: center;
            align-items: center;
            padding: 0;

            @include breakpoint($breakpoint-xl) {
              width: 100%;
              padding: 0 auto;
            }

            @include breakpoint($breakpoint-lg) {
              width: 100%;
              padding: 0;
            }

            @include breakpoint($breakpoint-md) {
              width: 100%;
              padding: 0 auto;
            }

            @include breakpoint($breakpoint-sm) {
              width: 100%;
              padding: 0;
            }

            @include breakpoint($breakpoint-xs) {
              width: 100%;
              padding: 0;
            }
          }
          .nft-modal-card {
            width: 600px;
            display: flex;
            flex-direction: column;
            align-content: center;
            justify-content: center;
            align-items: center;
            box-sizing: border-box;
            background: #f4f4f4;
            border: 4px solid var(--gradient-100);
            box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);
            border-radius: 10px;
            padding: 20px 20px 20px 20px;
            margin-bottom: 20px;

            @include breakpoint($breakpoint-lg) {
              width: 89%;
            }

            @include breakpoint($breakpoint-md) {
              width: 81%;
            }

            @include breakpoint($breakpoint-sm) {
              width: 81%;
            }

            @include breakpoint($breakpoint-xs) {
              width: 100%;
            }
          }

          .nft-modal-video {
            width: 100%;
            margin: 0 auto;
            padding: 0;
            overflow: hidden;
            background: #f4f4f4;
          }

          .nft-modal-image {
            width: 100%;
            margin: 0 auto;
            padding: 0;
            overflow: hidden;

            img,
            svg {
              width: 100%;
              height: 100%;
              object-fit: contain;
              overflow: hidden;
            }
          }

          .nft-modal-title {
            width: 100%;
            color: $black;
            font-size: 1.7rem;
            font-weight: 400;
            text-align: center;
            margin: 10px auto 0;
          }

          .nft-modal-description {
            color: $black;
            width: 100%;
            font-size: 16px;
            font-weight: normal;
            text-align: center;
            margin: 10px auto 0;
          }

          .nft-modal-external-url {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-align: center;
            margin: 10px auto 0;
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

          .nft-modal-add-attributes {
            color: #1a1a1a;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-align: center;
            margin: 10px auto 0;

            input {
              width: 86%;
              height: 30px;
              color: $black;
              background-color: #fdfdfd;
              border: 1px solid #d9d9d9;
              border-radius: 30px;
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

            input:read-only {
              color: #1a1a1a;
              border: 1px dashed #e0e0e0;
              letter-spacing: 1px;
              cursor: not-allowed;
            }

            input:focus {
              border: 1px dashed $mojo-blue;
              outline: none;
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
              cursor: pointer;

              &:hover {
                color: $black;
              }
            }

            .approved-button {
              color: $black;
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

      .right {
        width: 45%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;

        @include breakpoint($breakpoint-md) {
          width: 50%;
        }

        .form-container {
          display: flex;
          width: 98%;
          height: 505px;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          border: 4px solid var(--gradient-100);
          border-top-right-radius: 1rem;
          border-bottom-right-radius: 1rem;
          border-bottom-left-radius: 0;
          padding: 30px 20px;

          @include breakpoint($medium) {
            width: 100%;
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
            border-bottom-left-radius: 1em;
            border-bottom-right-radius: 1em;
            padding: 30px 0 30px 0;
          }

          h2 {
            font-size: 1.4rem;
            line-height: 1.5rem;
            text-align: center;
            padding-bottom: 2px;
            text-decoration: none;
            border-bottom: 1px solid;
            margin: 0 auto 10px;

            @include breakpoint($medium) {
              font-size: 1.6rem;
              line-height: 1.7rem;
            }
          }
        }

        input {
          color: #1a1a1a;
          background-color: #fdfdfd;
          border: 2px solid var(--gradient-100);
          border-radius: 10px;
          letter-spacing: 1px;
          font-size: 14px;
          width: 240px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: center;

          @include breakpoint($breakpoint-sm) {
            width: 300px;
          }

          @include breakpoint($breakpoint-md) {
            width: 300px;
          }

          @include breakpoint($breakpoint-xl) {
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
          border: 2px solid #2bb5f0;
          outline: none;
        }

        .select-row {
          position: relative;
          display: flex;
          flex-direction: row;
          justify-content: space-between;
          align-items: center;
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
          width: 265px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: center;

          /* reset */
          margin: 0;
          -webkit-box-sizing: border-box;
          -moz-box-sizing: border-box;
          box-sizing: border-box;
          -webkit-appearance: none;
          -moz-appearance: none;

          background-image: linear-gradient(45deg, transparent 50%, gray 50%),
            linear-gradient(135deg, gray 50%, transparent 50%),
            linear-gradient(to right, #ccc, #ccc);
          background-position: calc(100% - 20px) calc(1em + 2px), calc(100% - 15px) calc(1em + 2px),
            calc(100% - 2.5em) 0.5em;
          background-size: 5px 5px, 5px 5px, 1px 1.5em;
          background-repeat: no-repeat;

          @include breakpoint($breakpoint-sm) {
            width: 325px;
          }

          @include breakpoint($breakpoint-md) {
            width: 325px;
          }

          @include breakpoint($breakpoint-xl) {
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
          border: 2px solid #e9429b;
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

        .hidden {
          display: none;
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
      }

      .button-container {
        margin: 0 auto;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: space;
        align-items: center;

        @include breakpoint($medium) {
          flex-direction: row;
          align-content: center;
          justify-content: center;
          align-items: center;
        }

        .attr-button {
          color: #fff;
          background-color: #8d50f5;
          font-size: 18px;
          font-weight: bold;
          width: 100%;
          max-width: 360px;
          height: 55px;
          border: 0;
          padding-left: 71px;
          padding-right: 71px;
          border-radius: 10px;
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
          width: 100%;
          max-width: 300px;
          height: 55px;
          border: 2px solid #1c8bfe;
          padding-left: 20px;
          padding-right: 20px;
          border-radius: 10px;
          margin-right: 10px;
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
  section#mint-content .main section#mint .author {
    background-color: var(--gradient-800);
  }

  section#panel-upload {
    background-color: var(--gradient-800);

    .dropzone-box {
      span {
        color: #ffffff;
      }
    }

    .dropzone-details .dropzone-detail {
      color: #fff;
      background-color: var(--gradient-900);
    }

    .dropzone-is-loading {
      background-color: var(--gradient-700);

      .dropzone-loading--bar {
        background-color: var(--icon-color);
      }
    }
  }
}

@keyframes indeterminate {
  0% {
    left: -35%;
    right: 100%;
  }

  60% {
    left: 100%;
    right: -90%;
  }

  100% {
    left: 100%;
    right: -90%;
  }
}

@keyframes indeterminate-short {
  0% {
    left: -200%;
    right: 100%;
  }

  60% {
    left: 107%;
    right: -8%;
  }

  100% {
    left: 107%;
    right: -8%;
  }
}
</style>
