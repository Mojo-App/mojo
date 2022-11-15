<template>
  <section id="mint-content">
    <div class="main">
      <section id="mint">
        <h2>Mint a Music NFT</h2>
        <!-- Top Row -->
        <div class="row">
          <!-- Left Side -->

          <!-- MetaMask is NOT Connected -->
          <div v-if="!account" class="left">
            <p class="connect-message">
              Connect your MetaMask and mint your Audio/Media NFT's for your followers and
              subscribers allowing them to unlock bonus content and earn additional rewards.
            </p>
          </div>
          <!-- END MetaMask NOT Connected -->

          <!-- MetaMask is now Connected -->
          <div v-if="account" class="left">
            <!-- STEP 1 : Once user selects an asset and the file is uploaded to IPFS -->
            <section v-if="!imageUrl" id="panel-upload">
              <div class="content panel-upload--content">
                <div
                  class="panel-upload--dropzone"
                  :class="{ active: isDragged }"
                  @dragenter="onDragEnter"
                  @dragleave="onDragLeave"
                  @drop.prevent="onDropHandler"
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
                  </div>
                  <div class="dropzone-details">
                    <div class="dropzone-detail">{{ result.count }} files</div>
                    <div class="dropzone-detail">{{ fileSize(result.size) }}</div>
                  </div>
                </div>
              </div>
            </section>

            <!-- STEP 2 : We receive a content identifier and can show image and continue to add NFT main metadata in this window -->
            <section v-if="imageUrl" id="nft-modal">
              <div class="nft-modal-card">
                <div class="nft-modal-card-step-one">
                  <div v-if="getUrlProtocol(imageUrl) === 'mp4'" class="nft-video">
                    <video height="240" controls>
                      <source :src="imageUrl" type="video/mp4" />
                      Your browser does not support the video tag.
                    </video>
                  </div>
                  <div v-if="getUrlProtocol(imageUrl) === 'mp3'" class="nft-video">
                    <audio ref="player" height="240">
                      <source :src="imageUrl" type="audio/mpeg" />
                    </audio>
                    <video height="240" controls>
                      <source :src="getUrlProtocol(imageUrl)" type="video/mp3" />
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
                </div>
                <div class="nft-modal-card-step-two">
                  <div class="nft-modal-external-url">
                    {{ externalUrl }}
                  </div>
                  <div class="nft-modal-description">
                    {{ animationUrl }}
                  </div>
                  <div class="nft-modal-description">
                    {{ youtubeUrl }}
                  </div>
                  <div class="nft-modal-description">
                    {{ backgroundColor }}
                  </div>
                </div>
                <div class="nft-modal-card-step-three">
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
                </div>
                <!-- Control Panel -->
                <div class="nft-modal-approve">
                  <div v-show="!tokenId" class="file-image-link">
                    <a :href="imageUrl" title="Open in new tab" target="_blank"> ipfs link </a>
                  </div>
                  <button
                    v-show="!tokenId"
                    :class="!approvedMint ? 'approve-button' : 'approved-button'"
                    @click="ConfirmApprovedMint(true)"
                  >
                    {{ !approvedMint ? "approve" : "let's mint" }}
                  </button>
                  <div v-if="tokenId || tokenId === 0" class="file-table-link">
                    <a
                      :href="`https://testnet.tableland.network/query?mode=list&s=SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27category%27%2Ccategory%2C%27external_url%27%2Cexternal_url%2C%27background_color%27%2Cbackground_color%2C%27animation_url%27%2Canimation_url%2C%27youtube_url%27%2Cyoutube_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20Mojo_Music_80001_3847%20JOIN%20Mojo_Music_80001_3848%20ON%20Mojo_Music_80001_3847%2Etokenid%20%3D%20Mojo_Music_80001_3848%2Emaintable_tokenid%20WHERE%20tokenid%3D${tokenId}%20group%20by%20tokenid`"
                      title="View Tableland data"
                      target="_blank"
                    >
                      tableland
                    </a>
                  </div>
                </div>
                <!-- END Control Panel -->
              </div>
            </section>
          </div>
          <!-- END Step 2 -->
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
            <!-- Tab One is to add our main NFT metadata -->
            <div v-if="formTab === 'one'" id="form-tab-one" class="form-container">
              <h2>Mint NFT</h2>
              <div class="select-row">
                <label>Category</label>
                <div class="select-wrapper">
                  <select v-model="category">
                    <option value="" class="grey">Select a Category</option>
                    <option v-for="cat in musicCategories" :key="cat.id" :value="cat.value">
                      {{ cat.label }}
                    </option>
                  </select>
                </div>
              </div>
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
                <label>External link</label>
                <div class="input-wrapper">
                  <input
                    type="text"
                    placeholder="eg. https://opensea.io/collection/mojo-music"
                    v-model="externalUrl"
                    class="short"
                  />
                  <button
                    :disabled="!tokenId"
                    class="update-field-button"
                    @click="updateExternalUrl(externalUrl)"
                  >
                    update
                  </button>
                </div>
              </div>
              <div class="input-row hidden">
                <label>Background Color</label>
                <div class="input-wrapper">
                  <input
                    type="text"
                    placeholder="#ffffff"
                    v-model="backgroundColor"
                    class="short"
                  />
                  <button
                    class="update-field-button"
                    @click="updateBackgroundColor(backgroundColor)"
                  >
                    update
                  </button>
                </div>
              </div>
              <div class="input-row hidden">
                <div class="input-wrapper">
                  <input
                    type="text"
                    placeholder="Audio/Video Type"
                    v-model="audioVideoType"
                    readonly
                  />
                </div>
              </div>
              <!-- Data we receive after file upload HIDDEN -->
              <div class="input-row hidden">
                <div class="input-wrapper">
                  <input type="text" placeholder="Token ID" v-model="tokenId" />
                </div>
              </div>
              <div class="input-row hidden">
                <div class="input-wrapper">
                  <input type="text" placeholder="Content ID" v-model="cid" />
                </div>
              </div>
              <div class="input-row hidden">
                <div class="input-wrapper">
                  <input type="text" placeholder="Created" v-model="createdAt" readonly />
                </div>
              </div>
              <div class="input-row hidden">
                <div class="input-wrapper">
                  <input type="text" placeholder="Image Url" v-model="imageUrl" readonly />
                </div>
              </div>
              <div class="input-row hidden">
                <div class="input-wrapper">
                  <input type="text" placeholder="File Size" v-model="size" readonly />
                </div>
              </div>
              <!-- END Data we receive after file upload HIDDEN -->
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
            <!-- END Tab 1 -->

            <!-- Tab Two NFT Metadata Attributes -->
            <div v-if="formTab === 'two'" id="form-tab-two" class="form-container">
              <div class="input-row">
                <label>Title</label>
                <div class="input-wrapper">
                  <input type="text" v-model="title" class="short" />
                  <button class="update-field-button" @click="updateTitle(title)">update</button>
                </div>
              </div>
              <div class="input-row">
                <label>Website</label>
                <div class="input-wrapper">
                  <input type="text" v-model="website" class="short" />
                  <button class="update-field-button" @click="updateWebsite(website)">
                    update
                  </button>
                </div>
              </div>
              <div class="input-row">
                <label>Preview Link</label>
                <div class="input-wrapper">
                  <input type="text" v-model="preview" class="short" />
                  <button class="update-field-button" @click="updatePreview(preview)">
                    update
                  </button>
                </div>
              </div>
              <div class="input-row">
                <label>Audio/Video Link</label>
                <div class="input-wrapper">
                  <input type="text" v-model="audioVideoURL" class="short" />
                  <button class="update-field-button" @click="updateAudioVideoURL(audioVideoURL)">
                    update
                  </button>
                </div>
              </div>
              <div class="input-row">
                <label>Best Resolution</label>
                <div class="input-wrapper">
                  <input type="text" v-model="resolution" class="short" />
                  <button class="update-field-button" @click="updateResolution(resolution)">
                    update
                  </button>
                </div>
              </div>
              <!-- Button Row -->
              <div class="button-container">
                <button class="back-button" @click="switchToTab('one')">back</button>
                <button class="mint-done-button" @click="switchToTab('three')">next</button>
              </div>
              <!-- END Button Row -->
            </div>
            <!-- END Tab Two NFT Metadata Attributes -->

            <!-- Tab Three NFT Pricing -->
            <div v-if="formTab === 'three'" id="form-tab-three" class="form-container">
              <div class="input-row">
                <label>Animation Link</label>
                <div class="input-wrapper">
                  <input type="text" v-model="animationUrl" class="short" />
                  <button class="update-field-button" @click="updateAnimationUrl(animationUrl)">
                    update
                  </button>
                </div>
              </div>
              <div class="input-row">
                <label>Youtube Link</label>
                <div class="input-wrapper">
                  <input type="text" v-model="youtubeUrl" class="short" />
                  <button class="update-field-button" @click="updateYoutubeUrl(youtubeUrl)">
                    update
                  </button>
                </div>
              </div>
              <div class="nft-modal-add-license-attributes">
                <div class="select-row">
                  <label>License</label>
                  <div class="select-wrapper">
                    <select v-model="license" class="short">
                      <option value="" class="grey">Select a License</option>
                      <option v-for="license in licenses" :key="license.id" :value="license.value">
                        {{ license.label }}
                      </option>
                    </select>
                    <button class="update-field-button" @click="updateLicense(license)">
                      update
                    </button>
                  </div>
                </div>
                <div class="input-row hidden">
                  <label>Max Prints</label>
                  <div class="input-wrapper">
                    <input
                      type="text"
                      placeholder="default is one"
                      v-model="maxInvocations"
                      class="short"
                    />
                    <button
                      class="update-field-button"
                      @click="updateMaxInvocations(maxInvocations)"
                    >
                      update
                    </button>
                  </div>
                </div>
                <div class="input-row">
                  <label>Royalty Fee</label>
                  <div class="input-wrapper">
                    <input
                      type="text"
                      placeholder="max 5%"
                      v-model="royaltyPercentage"
                      class="short"
                    />
                    <button
                      class="update-field-button"
                      @click="updateRoyaltyPercentage(royaltyPercentage)"
                    >
                      update
                    </button>
                  </div>
                </div>
                <div class="input-row">
                  <label>Price</label>
                  <div class="input-wrapper">
                    <input type="text" v-model="price" class="short" />
                    <button class="update-field-button" @click="updatePrice(price)">update</button>
                  </div>
                </div>
              </div>
              <div class="button-container">
                <button class="back-button" @click="switchToTab('two')">back</button>
                <button class="mint-done-button" @click="switchToTab('four')">next</button>
              </div>
            </div>

            <div v-if="formTab === 'four'" id="form-tab-four" class="form-container">
              <h2>Custom Attributes</h2>
              <!-- STEP 3 : Show Add attributes form once NFT minted and we have a token id returned -->
              <div class="nft-modal-add-attributes">
                <div class="nft-attribute">
                  <div class="nft-attribute-icon">
                    <div class="input-wrapper">
                      <input
                        type="text"
                        name="traitIcon"
                        placeholder="enter an icon"
                        v-model="traitIcon"
                      />
                    </div>
                  </div>
                  <div class="nft-attribute-display-type">
                    <div class="input-wrapper">
                      <input
                        type="text"
                        name="traitDisplayType"
                        placeholder="enter a display type, eg. boost_number"
                        v-model="traitDisplayType"
                      />
                    </div>
                  </div>
                  <div class="nft-attribute-trait-type">
                    <div class="input-wrapper">
                      <input
                        type="text"
                        name="traitType"
                        placeholder="enter a trait type, eg. Stamina Increase"
                        v-model="traitType"
                      />
                    </div>
                  </div>
                  <div class="nft-attribute-value">
                    <div class="input-wrapper">
                      <input
                        type="text"
                        name="traitValue"
                        placeholder="enter a trait value, eg. 10"
                        v-model="traitValue"
                      />
                    </div>
                  </div>
                </div>
                <div class="button-container">
                  <button class="add-button" @click="AddNewAttribute()">
                    add new custom attribute
                  </button>
                </div>
              </div>
              <!-- Button Row -->
              <div class="button-container">
                <button class="back-button" @click="switchToTab('three')">back</button>
                <button class="update-button" @click="cancelMint()">finish</button>
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
import { Notyf } from "notyf";
import moment from "moment";

/* Import our Pinia Store & Refs */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Import our IPFS and NftStorage Services */
import { uploadBlob } from "../services/ipfs.js";
import { fileSize, generateLink } from "../services/helpers";
// import { nftStorage } from "../services/nftStorage.js";
import tablelandCRUD from "../services/tablelandCRUD.js";
import JSConfetti from "js-confetti";

/* Import Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";
import ArrowBack from "../assets/svgs/ArrowBack.vue";

/* Import Smart Contract ABI and Mojo Contract Address */
import contractAbi from "../../../artifacts/contracts/mojo_ERC721.sol/MOJO.json";
const contractAddress = "0x4dBaa276d66B5dEAAc9Ca718773a7CE09f989741";

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
    const { loading, minting, account, musicCategories } = storeToRefs(store);

    const licenses = ref([
      { id: 1, label: "", value: "" },
      { id: 2, label: "", value: "" },
      { id: 3, label: "", value: "" },
    ]);

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
    const updatedAt = ref("");

    /* NFT Form Metadata Attributes */
    const attributes = ref([]);
    const audioVideoType = ref("");
    const maxInvocations = ref(null);
    const royaltyPercentage = ref(null);
    const price = ref(null);
    const title = ref("");
    const license = ref("");
    const website = ref("");
    const preview = ref("");
    const externalUrl = ref("");
    const animationUrl = ref("");
    const youtubeUrl = ref("");
    const audioVideoURL = ref("");
    const backgroundColor = ref("");
    const resolution = ref("");

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
        notyf.error(`Please select a category to continue!`);
        switchToTab("one");
        return;
      }
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
          console.log("%c🎧 Mojo Contract Address:  %s ", styles, contractAddress);

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
          //   preview.value,
          //   audioVideoURL.value,
          //   animationUrl.value,
          //   youtubeUrl.value,
          //   backgroundColor.value,
          //   resolution.value,
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

          console.log("name :", name.value);
          console.log("description :", description.value);
          console.log("imageUrl :", imageUrl.value);
          console.log("category :", category.value);

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
            category.value.toString(),
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
              `%c🧬 NFT Minted on Polygon Mumbai, see transaction: https://mumbai.polygonscan.com/tx/${nftTxn.hash} %s`,
              stylesPolygon,
              nftTxn.hash
            );
            /* Remove loading indicator and show success notification */
            notyf.dismiss(loadingIndicator);
            notyf.open({
              type: "success",
              message: `NFT minted successfully!`,
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
     * Update update_external_url of Mojo Music NFT
     */
    const updateExternalUrl = async (externalUrl) => {
      console.log("externalUrl", externalUrl);

      /* This is the attribute number in attribute_table, an NFT can have many attributes */
      if (!externalUrl) {
        console.log(`Please enter a externalUrl to continue!`);
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
            "externalUrlUpdated",
            (receiver, timestamp, metadata_table_id, external_url, token_id) => {
              console.log("Receiver :", receiver);

              updatedAt.value = moment.unix(timestamp).toString();
              console.log("Updated At :", traitUpdatedAt.value);

              const metadataTableId = metadata_table_id.toNumber();
              console.log("Metadata Table Id :", metadataTableId);

              const tokenId = token_id.toNumber();
              console.log("Token Id :", tokenId);

              const externalUrlNew = external_url.toString();
              console.log("externalUrl :", externalUrlNew);

              /* Stop loading */
              store.setLoading(false);
            }
          );

          let tx = await contract.update_external_url(
            BigNumber.from(tokenId.value),
            externalUrl.value.toString()
          );

          const receipt = await tx.wait();
          const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
          console.log("%c We just updated the external url %s ", stylesReceipt, tx.hash);

          /* Check our Transaction results */
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c Mojo Music NFT updated external url, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
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
     * Update background_color of Mojo Music NFT
     */
    const updateBackgroundColor = async (backgroundColor) => {
      console.log("backgroundColor", backgroundColor);

      /* This is the attribute number in attribute_table, an NFT can have many attributes */
      if (!backgroundColor) {
        console.log(`Please enter a background color to continue!`);
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
            "backgroundColorUpdated",
            (receiver, timestamp, metadata_table_id, background_color, token_id) => {
              console.log("Receiver :", receiver);

              updatedAt.value = moment.unix(timestamp).toString();
              console.log("Updated At :", traitUpdatedAt.value);

              const metadataTableId = metadata_table_id.toNumber();
              console.log("Metadata Table Id :", metadataTableId);

              const tokenId = token_id.toNumber();
              console.log("Token Id :", tokenId);

              const backgroundColorNew = background_color.toString();
              console.log("backgroundColor :", backgroundColorNew);

              /* Stop loading */
              store.setLoading(false);
            }
          );

          let tx = await contract.update_background_color(
            BigNumber.from(tokenId.value),
            backgroundColor.value.toString()
          );

          const receipt = await tx.wait();
          const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
          console.log("%c We just updated the background color %s ", stylesReceipt, tx.hash);

          /* Check our Transaction results */
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c Mojo Music NFT updated background color, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
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
     * Update animation_url of Mojo Music NFT
     */
    const updateAnimationUrl = async (animationUrl) => {
      console.log("animationUrl", animationUrl);

      /* This is the attribute number in attribute_table, an NFT can have many attributes */
      if (!animationUrl) {
        console.log(`Please enter a background color to continue!`);
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
            "animationUrlUpdated",
            (receiver, timestamp, metadata_table_id, animation_url, token_id) => {
              console.log("Receiver :", receiver);

              updatedAt.value = moment.unix(timestamp).toString();
              console.log("Updated At :", traitUpdatedAt.value);

              const metadataTableId = metadata_table_id.toNumber();
              console.log("Metadata Table Id :", metadataTableId);

              const tokenId = token_id.toNumber();
              console.log("Token Id :", tokenId);

              const animationUrlNew = animation_url.toString();
              console.log("animationUrl :", animationUrlNew);

              /* Stop loading */
              store.setLoading(false);
            }
          );

          let tx = await contract.update_animation_url(
            BigNumber.from(tokenId.value),
            animationUrl.value.toString()
          );

          const receipt = await tx.wait();
          const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
          console.log("%c We just updated the animation url %s ", stylesReceipt, tx.hash);

          /* Check our Transaction results */
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c Mojo Music NFT updated animation url, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
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
     * Update update_youtube_url of Mojo Music NFT
     */
    const updateYoutubeUrl = async (youtubeUrl) => {
      console.log("youtubeUrl", youtubeUrl);

      /* This is the attribute number in attribute_table, an NFT can have many attributes */
      if (!youtubeUrl) {
        console.log(`Please enter a background color to continue!`);
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
            "youtubeUrlUpdated",
            (receiver, timestamp, metadata_table_id, youtube_url, token_id) => {
              console.log("Receiver :", receiver);

              updatedAt.value = moment.unix(timestamp).toString();
              console.log("Updated At :", traitUpdatedAt.value);

              const metadataTableId = metadata_table_id.toNumber();
              console.log("Metadata Table Id :", metadataTableId);

              const tokenId = token_id.toNumber();
              console.log("Token Id :", tokenId);

              const youtubeUrlNew = youtube_url.toString();
              console.log("youtubeUrl :", youtubeUrlNew);

              /* Stop loading */
              store.setLoading(false);
            }
          );

          let tx = await contract.update_youtube_url(
            BigNumber.from(tokenId.value),
            youtubeUrl.value.toString()
          );

          const receipt = await tx.wait();
          const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
          console.log("%c We just updated the youtube url %s ", stylesReceipt, tx.hash);

          /* Check our Transaction results */
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c Mojo Music NFT updated youtube url, see transaction: https://polygonscan.com/tx/${tx.hash} %s`,
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

      /* Load Tableland CRUD */
      const tableland = new tablelandCRUD();
      const mNFT = await tableland.updateNFT(
        tokenId.value,
        cid.value,
        name.value,
        description.value,
        externalUrl.value,
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
        preview.value,
        audioVideoURL.value,
        animationUrl.value,
        youtubeUrl.value,
        backgroundColor.value,
        resolution.value
      );
      console.log("Mojo Music NFT Data: ", mNFT);

      if (mNFT) {
        /* Console log with some style */
        const stylesRowEntry = ["color: white", "background: #32c33a"].join(";");
        console.log(`%c NFT Data : %s`, stylesRowEntry, mNFT);
        /* Remove loading indicator and show success notification */
        notyf.dismiss(loadingIndicator);
        notyf.open({
          type: "success",
          message: `NFT metadata updated`,
        });

        cancelMint();
        return;
      }
      notyf.dismiss(loadingIndicator);
      notyf.error(`Error adding a new table row, please try again!`);
      // switchToTab("two");
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
      preview.value = "";
      audioVideoType.value = "";
      audioVideoURL.value = "";
      backgroundColor.value = "";
      resolution.value = "";
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
      /* Set to NFT Main Attributes Tab */
      switchToTab("one");
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
        // store.resetNftFiles();
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

    /**
     * Fetch NFT Audio/Media category data from Tableland
     */
    async function fetchMusicCategories() {
      try {
        await store.getCategories();
      } catch (error) {
        console.log(error);
      }
    }

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
      await fetchMusicCategories();
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
      licenses,
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
      preview,
      audioVideoType,
      audioVideoURL,
      backgroundColor,
      resolution,
      musicCategories,
      size,
      createdAt,
      approvedMint,
      cancelMint,
      ConfirmApprovedMint,
      switchToTab,
      mintNFT,
      updateExternalUrl,
      updateBackgroundColor,
      updateAnimationUrl,
      updateYoutubeUrl,
      AddNewAttribute,
      editTrait,
      updateTraitIcon,
      updateTraitDisplayType,
      updateTraitType,
      updateTraitValue,
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
      fetchMusicCategories,
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

  .bg-shape {
    background: #fff;
    background-image: url("./BlackCorner.png");
    background-repeat: no-repeat;
    background-position: center right;
    background-size: auto;
  }

  .main {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
    overflow: scroll;
    @include breakpoint($break-ssm) {
      height: 99%;
    }

    section#mint {
      height: 100%;
      color: $black;
      background: $mojo-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      overflow: scroll;
      @include breakpoint($break-ssm) {
        justify-content: flex-start;
      }

      .row {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;
        @include breakpoint($break-ssm) {
          flex-direction: column;
        }
      }

      .left {
        width: 430px;
        height: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: flex-end;
        overflow: hidden;
        @include breakpoint($break-md) {
          width: 100%;
        }
        @include breakpoint($break-sm) {
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

          @include breakpoint($break-ssm) {
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
                color: $black;
                font-size: 0.8rem;
              }
            }

            .dropzone-details {
              color: $black;
              position: absolute;
              display: flex;
              bottom: 1rem;
              right: 1rem;

              .dropzone-detail {
                color: $black;
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
          width: 100%;
          height: 100%;
          color: $black;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-content: center;
          align-items: center;
          padding: 0;
          border-top-left-radius: 1rem;
          border-bottom-left-radius: 1rem;
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;

          @include breakpoint($break-ssm) {
            border-top-left-radius: 1rem;
            border-top-right-radius: 1rem;
            border-bottom-left-radius: 0;
          }

          @include breakpoint($break-ssm) {
            border-top-left-radius: 1rem;
            border-top-right-radius: 1rem;
            border-bottom-left-radius: 0;
          }

          @include breakpoint($break-xs) {
            padding: 20px 0;
          }

          .nft-modal-card {
            width: 84%;
            max-width: 450px;
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
            padding: 15px;

            @include breakpoint($break-xl) {
              width: 84%;
            }

            @include breakpoint($break-md) {
              width: 82%;
            }

            @include breakpoint($break-sm) {
              width: 81%;
            }

            @include breakpoint($break-xs) {
              width: 90%;
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
              display: block;
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
            color: $black;
            width: 100%;
            font-size: 14px;
            font-weight: normal;
            text-align: center;
            margin: 10px auto 0;
          }

          .nft-modal-edit-attributes {
            color: $black;
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

          .nft-modal-add-attributes {
            color: $black;
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
              color: $black;
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
              transition: 0.6s;
              cursor: pointer;

              &:hover {
                color: $black;
              }
            }

            .approved-button {
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
              transition: 0.6s;
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
                transition: 0.6s;
                &:hover {
                  color: $mojo-green;
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
                transition: 0.6s;

                &:hover {
                  color: $mojo-green;
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
              transition: 0.6s;
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
        padding: 0;

        @include breakpoint($break-md) {
          width: 100%;
        }

        .form-container {
          display: flex;
          width: 100%;
          min-height: 570px;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          border: 2px solid var(--gradient-100);
          border-top-right-radius: 1rem;
          border-bottom-right-radius: 1rem;
          border-bottom-left-radius: 0;
          padding: 20px 0 10px 10px;
          background-color: $white;

          @include breakpoint($break-sm) {
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
            border-bottom-left-radius: 1em;
            border-bottom-right-radius: 1em;
            padding: 15px 0 10px 0;
          }

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

        .input-wrapper input.short {
          padding-left: 20px;
          width: 230px;
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

        .select-wrapper select.short {
          width: 230px;
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

        .update-field-button:disabled {
          background: #c6c6c6;
          color: #101010;
          cursor: not-allowed;
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

        .grey {
          color: #a8a8a8 !important;
          letter-spacing: 1px;
        }

        .hidden {
          display: none;
        }
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

        .back-button {
          color: $white;
          background-color: $mojo-dark-blue;
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
            color: $mojo-green;
          }
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
          color: $white;
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
            color: $black;
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
          border-radius: 30px;
          padding: 4px 15px;
          height: auto;
          border: 0;
          margin: 15px auto 30px;
          transition: 0.6s;
          cursor: pointer;

          &:hover {
            color: $black;
          }
        }

        .update-button {
          color: $white;
          background-color: $mojo-green;
          font-size: 18px;
          font-weight: bold;
          height: 55px;
          border: 0;
          border-radius: 30px;
          padding-left: 65px;
          padding-right: 65px;
          margin: 10px 1% 10px 0;
          transition: 0.6s;
          cursor: pointer;

          &:hover {
            color: $black;
          }
        }

        .update-button:disabled {
          background: #c6c6c6;
          color: #101010;
          cursor: not-allowed;
        }
      }

      h2 {
        color: $white;
        font-size: 34px;
        font-style: normal;
        font-weight: 700;
        line-height: 42px;
        text-align: center;
        margin-block-start: 0;
        margin-block-end: 0.3em;

        @include breakpoint($break-ssm) {
          font-size: 2.25rem;
          margin-block-start: 0.3em;
          margin-block-end: 0.2em;
        }
      }

      a {
        color: $black;
        font-weight: bold;
        border-bottom: 1px solid $black;
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
