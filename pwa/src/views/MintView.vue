<template>
  <section id="content">
    <div class="main">
      <section id="mint">
        <h2>Mint an Audio/Media NFT</h2>
        <!-- Top Row -->
        <div class="row">
          <!-- Left Side -->
          <!-- MetaMask Connected -->
          <div v-if="account" class="left">
            <section id="panel-upload">
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
          </div>
          <!-- END MetaMask Connected -->
          <!-- MetaMask NOT Connected -->
          <div v-if="!account" class="left">
            <p class="connect-message">
              Connect your MetaMask and mint your Audio/Media NFT's for your followers and
              subscribers allowing them to unlock bonus content and earn additional rewards.
            </p>
          </div>
          <!-- END MetaMask NOT Connected -->
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
              <h2>1. Create your NFT</h2>
              <div class="input-row">
                <input type="text" placeholder="Token ID" v-model="tokenId" />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Content ID" v-model="cid" />
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
              <div class="input-row hidden">
                <input type="text" placeholder="Created" v-model="createdAt" readonly />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Add an external link" v-model="externalUrl" />
              </div>
              <!-- Button Row -->
              <div v-if="account && formTab === 'one'" class="button-container">
                <button
                  v-if="!tokenId"
                  class="mint-button"
                  :disabled="!name || !description"
                  @click="mintNFT()"
                >
                  Mint NFT
                </button>
                <button v-if="tokenId" class="mint-button" @click="setExternalUrl(tokenId)">
                  Set URL
                </button>
              </div>
              <!-- END Button Row -->
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
                <button class="update-button" @click="createNFTRow()">Finish NFT</button>
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
import { ethers } from "ethers";
import { BigNumber } from "bignumber.js";
import moment from "moment";
import { Notyf } from "notyf";
import { storeToRefs } from "pinia";
/* Import our Pinia Store */
import { useStore } from "../store";
/* Import our IPFS and NftStorage Services */
import { uploadBlob } from "../services/ipfs.js";
import { fileSize, generateLink } from "../services/helpers";
import { nftStorage } from "../services/nftStorage.js";

import JSConfetti from "js-confetti";

/* Import Smart Contract ABI */
import contractAbi from "../../../artifacts/contracts/MojoCore.sol/MojoCore.json";
/* Manually set our Contract Address */
const contractAddress = "0x6b9482bD2EEd7814EE5a88Cc93f687a3961D27Fb";

/* Console log with some style */
const stylesContract = ["color: black", "background: #e9429b"].join(";");
console.log("%c🏦 Mojo Contract Address %s 🏦", stylesContract, contractAddress);
const stylesAbi = ["color: black", "background: cyan"].join(";");
console.log("%c🧭 Contract ABI Source %s 🧭", stylesAbi, contractAbi.sourceName);

/* Import Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";
import ArrowBack from "../assets/svgs/ArrowBack.vue";
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
    // Init Store
    const store = useStore();
    // 🦊 Metamask Account
    const { account } = storeToRefs(store);
    // Set Form Tab
    const formTab = ref("one");

    // File Uploader
    const fileRef = ref(null);
    const isDragged = ref(false);
    const finished = ref(0);
    const isUploading = ref(false);

    // NFT Form Metadata fields
    const tokenId = ref("");
    const rowId = ref("");
    const cid = ref("");
    // Visible on form, above hidden on form
    const name = ref("");
    const description = ref("");
    const externalUrl = ref("");
    const imageUrl = ref(null);
    // Calculated on Mint and IPFS upload
    const size = ref("");
    const createdAt = ref("");

    // NFT Form Metadata Attributes
    const audioVideoType = ref("");
    const maxInvocations = ref(null);
    const royaltyPercentage = ref(null);
    const price = ref(null);
    const title = ref("");
    const category = ref("");
    const license = ref("");
    const website = ref("");
    const longDescription = ref("");
    const preview = ref("");
    const audioVideoURL = ref("");
    const animationURL = ref("");
    const youtubeURL = ref("");
    const resolution = ref("");
    const duration = ref("");

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

    /**
     * Mint Mojo Core NFT
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
        message: "⏳ Please wait while we get our mojo on! Minting NFT shortly...",
      });

      /**
       * Mint our NFT with fresh metadata
       */
      try {
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          const contract = new ethers.Contract(contractAddress, contractAbi.abi, signer);
          /* Console log with some style */
          const styles = ["color: black", "background: green"].join(";");
          console.log("%c🎧 Mojo Core Smart Contract Address:  %s 🎧", styles, contractAddress);

          /**
           *  Receive Emitted Event from Contract
           *  @dev See NewNftMinted emitted from our smart contract safeMint function
           */
          contract.on("NewNftMinted", (receiver, timestamp, newTokenId) => {
            console.log("receiver ", receiver);

            createdAt.value = moment.unix(timestamp).toString();
            console.log("createdAt.value ", createdAt.value);

            let tokenIdBigNo = new BigNumber(newTokenId);

            console.log("tokenId ", tokenIdBigNo);
            tokenId.value = newTokenId.toNumber();
            console.log("tokenId.value ", tokenId.value);
          });

          /* Store NFT Metadata on NFT.Storage */
          const nftStorageTMetadataURI = await nftStorage(
            name.value,
            description.value,
            imageUrl.value,
            size.value,
            createdAt.value,
            audioVideoType.value,
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
          /* Console log with some style */
          const stylesNFTStorage = ["color: black", "background: #f23f3f"].join(";");
          console.log(
            "%c💾 NFT.Storage ipfs:// link :  %s 💾",
            stylesNFTStorage,
            nftStorageTMetadataURI
          );

          /* Check our Transaction results */
          if (!nftStorageTMetadataURI) return;

          /* Mint our NFT using complex Struct */
          let nftTxn = await contract.safeMint(
            signer.getAddress(),
            nftStorageTMetadataURI,
            category.value
          );
          // let nftTxn = await contract.safeMint(signer.getAddress());

          /* Console log with some style */
          const stylesMining = ["color: black", "background: yellow"].join(";");
          console.log("%c⛏ Mining...please wait!  %s ⛏", stylesMining, nftTxn.hash);

          // The OpenZeppelin base ERC721 contract emits a Transfer event
          // when a token is issued. tx.wait() will wait until a block containing
          // our transaction has been mined and confirmed. The transaction receipt
          // contains events emitted while processing the transaction.
          const receipt = await nftTxn.wait();
          /* Console log with some style */
          const stylesReceipt = ["color: black", "background: #e9429b"].join(";");
          console.log("%c💎 We just mined another gem! %s 💎", stylesReceipt, nftTxn.hash);

          /* Check our Transaction results */
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            /* Console log with some style */
            const stylesPolygon = ["color: white", "background: #7e44df"].join(";");
            console.log(
              `%c🧬 NFT Minted on Polygon, see transaction:<br /> https://mumbai.polygonscan.com/tx/${nftTxn.hash} %s`,
              stylesPolygon,
              nftTxn.hash
            );
            /* Remove loading indicator and show success notification */
            notyf.dismiss(loadingIndicator);
            notyf.open({
              type: "success",
              message: `🧬 NFT has been minted successfully, see transaction<br />https://mumbai.polygonscan.com/tx/${nftTxn.hash}`,
            });
          }
          /* Set to NFT Main Attributes Tab */
          switchToTab("two");
          jsConfettiSuccess(["🚀", "🔥", "🏴‍☠️", "🌈", "⚡️", "💥", "✨", "💫", "🌸", "🦄"]);
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
            "SetNftExternalUrl",
            (receiver, timestamp, metadataTableId, metadataTable, tokenId) => {
              console.log("receiver ", receiver);

              console.log("timestamp ", timestamp);
              createdAt.value = moment.unix(timestamp).toString();
              console.log("createdAt.value ", createdAt.value);

              let tokenIdBigNo = new BigNumber(tokenId);
              console.log("tokenId ", tokenIdBigNo);
              rowId.value = tokenIdBigNo.toNumber();
              console.log("rowId.value ", rowId.value);

              console.log("metadataTableId ", metadataTableId);
              console.log("metadataTable ", metadataTable);
            }
          );
          let nftTxn = await contract.setExternalURL(
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
        /* Reset our NFT Metadata Form Values */
        tokenId.value = "";
        rowId.value = "";
        cid.value = "";
        name.value = "";
        description.value = "";
        externalUrl.value = "";
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
        /* Set to NFT Main Attributes Tab */
        switchToTab("one");
        return;
      }
      notyf.dismiss(loadingIndicator);
      notyf.error(`Error adding a new table row, please try again!`);
      switchToTab("two");
      return;
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
      /**
       * @dev Can try NFT.Storage here instead
       */
      const uploadResult = await uploadBlob(file);

      finished.value++;
      const { error } = uploadResult;
      if (error && error instanceof Error) {
        notyf.error(error.message);
        return uploadResult;
      }
      /* Set our NFT Metadata Form Values using IPFS best practises */
      cid.value = uploadResult.data.cid;
      /* Strip image type off our name eg, .png, .jpeg */
      name.value = uploadResult.data.file.name.substring(
        0,
        uploadResult.data.file.name.lastIndexOf(".")
      );
      /* Generate and IPFS URI for NFT's */
      imageUrl.value = generateLink(uploadResult.data);

      /* Set details from file upload */
      audioVideoType.value = uploadResult.data.file.type;
      size.value = fileSize(uploadResult.data.file.size);
      createdAt.value = uploadResult.data.file.created_at;
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
        notyf.error(`Oops! an error while processing your files.`, error.message);
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

    onMounted(() => {
      checkIfWalletIsConnected();
    });

    return {
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
      imageUrl,
      maxInvocations,
      royaltyPercentage,
      price,
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
      switchToTab,
      mintNFT,
      setExternalUrl,
      createNFTRow,
      generateLink,
      fileSize,
      onDragEnter,
      onDragLeave,
      onDropHandler,
      openSelectFile,
      onFileChangedHandler,
      checkIfWalletIsConnected,
      jsConfettiSuccess,
    };
  },
};
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#content {
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
      background: #fff;
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
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($medium) {
          flex-direction: row;
          align-content: center;
          justify-content: center;
          align-items: center;
        }
      }

      .left {
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: flex-end;

        @include breakpoint($breakpoint-sm) {
          width: 50%;
        }

        @include breakpoint($breakpoint-md) {
          width: 50%;
        }

        @include breakpoint($breakpoint-xl) {
          width: 60%;
        }

        .connect-message {
          max-width: 440px;
        }

        section#panel-upload {
          background-color: var(--gradient-100);
          border-top-left-radius: 1rem;
          border-top-right-radius: 1rem;
          border-bottom-left-radius: 0;
          width: 100%;
          height: 100%;

          @include breakpoint($medium) {
            margin-top: 0;
            padding-top: 0;
            border-top-left-radius: 1rem;
            border-bottom-left-radius: 1rem;
            border-top-right-radius: 0;
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
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: flex-start;

        @include breakpoint($breakpoint-sm) {
          width: 50%;
        }

        @include breakpoint($breakpoint-md) {
          width: 50%;
        }

        @include breakpoint($breakpoint-xl) {
          width: 40%;
        }

        .form-container {
          display: flex;
          width: 99%;
          height: 505px;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          border: 4px solid var(--gradient-100);
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;
          border-bottom-left-radius: 1em;
          border-bottom-right-radius: 1em;
          padding: 30px 0 30px 0;

          @include breakpoint($medium) {
            width: 100%;
            border-top-right-radius: 1rem;
            border-bottom-right-radius: 1rem;
            border-bottom-left-radius: 0;
            padding: 30px 20px;
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
  section#content .main section#mint .author {
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
