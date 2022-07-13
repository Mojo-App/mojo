<template>
  <section id="content">
    <div class="main">
      <section id="connect">
        <h2>Mint an Audio/Media NFT</h2>
        <!-- Top Row -->
        <div class="row">
          <!-- Left Side -->
          <!-- MetaMask Connected -->
          <div v-if="currentAccount" class="left">
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
          <div v-if="!currentAccount" class="left">
            <p class="connect-message">
              Connect your MetaMask and mint your Audio/Media NFT's for your followers and
              subscribers allowing them to unlock bonus content and earn additional rewards.
            </p>
          </div>
          <!-- END MetaMask NOT Connected -->
          <!-- END Left Side -->
          <!-- Right Side -->
          <!-- MetaMask NOT Connected -->
          <div v-if="!currentAccount" class="right">
            <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" btnSize="large" />
          </div>
          <!-- END MetaMask NOT Connected -->
          <!-- MetaMask Connected -->
          <div v-if="currentAccount" class="right">
            <div v-if="formTab === 'one'" id="form-tab-one" class="form-container">
              <h2>NFT Metadata</h2>
              <div class="input-row hidden">
                <input type="text" placeholder="Token ID" v-model="tokenId" />
              </div>
              <div class="input-row hidden">
                <input type="text" placeholder="Content ID" v-model="cid" />
              </div>
              <div class="input-row hidden">
                <input type="text" v-model="backgroundColor" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Name" v-model="name" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Image Url" v-model="imageUrl" />
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
              <div class="input-row">
                <input type="text" placeholder="Enter a description" v-model="description" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Add an external link" v-model="externalUrl" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Max invocations" v-model="maxInvocations" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Royalty Percentage" v-model="royaltyPercentage" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Price" v-model="price" />
              </div>
              <!-- Button Row -->
              <div v-if="currentAccount && formTab === 'one'" class="button-container">
                <button v-if="!tokenId" class="mint-button" @click="mintNFT()">Mint NFT</button>
              </div>
              <!-- END Button Row -->
            </div>

            <div v-if="formTab === 'two'" id="form-tab-two" class="form-container">
              <h2>Metadata Attributes</h2>
              <div class="input-row">
                <input type="text" placeholder="Track Title" v-model="title" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Category" v-model="category" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="License" v-model="license" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Website Link" v-model="website" />
              </div>
              <!-- <div class="input-row">
                <input type="text" placeholder="Long Description" v-model="longDescription" />
              </div> -->
              <div class="input-row">
                <input type="text" placeholder="Preview Link" v-model="preview" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Audio/Video Link" v-model="audioVideoURL" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Resolution" v-model="resoultion" />
              </div>
              <div class="input-row">
                <input type="text" placeholder="Duration" v-model="duration" />
              </div>
              <!-- Button Row -->
              <div v-if="currentAccount && formTab === 'two'" class="button-container">
                <button class="back-button" @click="goBack">🔙</button>
                <button class="update-button" @click="updateNFT(tokenId)">Update NFT</button>
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
import { ref, computed, onMounted } from 'vue';
import { Notyf } from 'notyf';
import { useStore } from '../store';

import { uploadBlob } from '../services/ipfs.js';
import { fileSize, generateLink } from '../services/helpers';

import { ethers } from 'ethers';
import contractAbi from '../../../artifacts/contracts/MojoCore.sol/MojoCore.json';
import ConnectWalletButton from '../components/ConnectWalletButton.vue';
console.log('contractAbi: ', contractAbi);

import ArrowBack from '../assets/svgs/ArrowBack.vue';

export default {
  name: 'MintView',
  components: [ConnectWalletButton, ArrowBack],
  setup() {
    /* Create an instance of Notyf */
    var notyf = new Notyf({
      duration: 3000,
      position: {
        x: 'center',
        y: 'bottom',
      },
      types: [
        {
          type: 'loading',
          background: 'orange',
          duration: 3000,
          dismissible: true,
          icon: {
            className: 'icon icon-loading',
            tagName: 'i',
          },
        },
        {
          type: 'success',
          background: 'green',
          duration: 10000,
          dismissible: true,
          icon: {
            className: 'icon icon-success',
            tagName: 'i',
          },
        },
      ],
    });
    const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
    // Init Store
    const store = useStore();
    // Metamask Account
    const currentAccount = ref();
    // Form Tab Selected
    const formTab = ref('one');
    // File Uploader
    const fileRef = ref(null);
    const isDragged = ref(false);
    const finished = ref(0);
    const isUploading = ref(false);

    // NFT Form Metadata
    const tokenId = ref();
    const cid = ref('');
    const name = ref('');
    const description = ref('');
    const externalUrl = ref('');
    const imageUrl = ref('');
    const backgroundColor = ref('ffffff');

    // NFT Form Metadata Attributes
    const audioVideoType = ref('');
    const size = ref('');
    const maxInvocations = ref(null);
    const royaltyPercentage = ref(null);
    const price = ref(null);
    const title = ref('');
    const category = ref('');
    const license = ref('');
    const website = ref('');
    const longDescription = ref('');
    const preview = ref('');
    const audioVideoURL = ref('');
    const resoultion = ref('');
    const duration = ref('');
    const createdAt = ref('');

    /**
     * Check if our Wallet is Connected to Metamask
     */
    const checkIfWalletIsConnected = async () => {
      try {
        /*
         * First make sure we have access to window.ethereum
         */
        const { ethereum } = window;

        if (!ethereum) {
          notyf.error(`Please connect Metamask to continue!`);
          console.log('Error: No ethereum window object');
          return;
        } else {
          console.log('We have an ethereum object', ethereum);
        }

        const accounts = await ethereum.request({ method: 'eth_accounts' });

        if (accounts.length !== 0) {
          const account = accounts[0];
          currentAccount.value = account;
        } else {
          console.log('No authorized accounts');
        }
      } catch (error) {
        console.log(error);
      }
    };

    /**
     * Mint our NFT
     */
    const mintNFT = async () => {
      /**
       * Some very basic form validation, these are loaded after IPFS upload
       * but users can edit so we still need some validation in UI
       */
      if (!name.value) {
        notyf.error(`Please enter a name to continue!`);
        formTab.value = 'one';
        return;
      }
      if (name.value.length < 3) {
        notyf.error(`NFT name must be longer then 3 characters!`);
        formTab.value = 'one';
        return;
      }
      if (!imageUrl.value) {
        notyf.error(`Please enter a imageUrl to continue!`);
        formTab.value = 'one';
        return;
      }
      if (imageUrl.value.length < 10) {
        notyf.error(`NFT image Url must be longer then 10 characters!`);
        formTab.value = 'one';
        return;
      }
      /**
       * Some very basic form validation on a required description field
       */
      if (!description.value) {
        notyf.error(`Please enter a description to continue!`);
        formTab.value = 'one';
        return;
      }
      if (description.value.length < 10) {
        notyf.error(`NFT description must be longer then 10 characters!`);
        formTab.value = 'one';
        return;
      }

      /* Init loading indicator */
      const loadingIndicator = notyf.open({
        type: 'loading',
        message: 'Please wait, we generate shorten link for you.',
      });

      /**
       * Mint our NFT with fresh metadata
       */
      try {
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          /**
           *  @dev Note: Reset this once Contracts deployed or re-dployed
           */
          const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi.abi, signer);
          console.log('Talk to the wallet and pay gas fees', signer);

          let nftTxn = await contract.safeMint(
            signer,
            name.value,
            description.value,
            imageUrl.value,
            externalUrl.value,
            backgroundColor.value
          );
          console.log('Minting Core NFT...please wait!');

          // The OpenZeppelin base ERC721 contract emits a Transfer event
          // when a token is issued. tx.wait() will wait until a block containing
          // our transaction has been mined and confirmed. The transaction receipt
          // contains events emitted while processing the transaction.
          const receipt = await nftTxn.wait();
          console.log('receipt', receipt);
          tokenId.value = receipt.tokenId;

          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            console.log(
              `NFT Minted, see transaction: https://mumbai.polygonscan.com/txs/${nftTxn.hash}`
            );
            notyf.dismiss(loadingIndicator);
            notyf.open({
              type: 'success',
              message: `NFT has been minted successfully, see transaction: https://mumbai.polygonscan.com/txs/${nftTxn.hash}`,
            });
            /* Set to NFT Metadata Attributes Tab */
            this.addNFTAttributesTab();
          }
        } else {
          notyf.dismiss(loadingIndicator);
          notyf.error("Ethereum object doesn't exist!");
          console.log("Ethereum object doesn't exist!");
        }
      } catch (error) {
        notyf.dismiss(loadingIndicator);
        console.log('error', error);
      }
    };

    const updateNFT = async (tokenId) => {
      console.log('Lets update our NFT!');
      if (!tokenId.value) {
        notyf.error(`We need a Token Id to continue!`);
        return;
      }
      if (!name.value) {
        notyf.error(`Please enter a name to continue!`);
        return;
      }
      if (name.value.length < 3) {
        notyf.error(`NFT name must be longer then 3 characters!`);
        return;
      }
      if (!description.value) {
        notyf.error(`Please enter a description to continue!`);
        return;
      }
      if (description.value.length < 10) {
        notyf.error(`NFT description must be longer then 10 characters!`);
        return;
      }
      if (!externalUrl.value) {
        notyf.error(`Please enter a externalUrl to continue!`);
        return;
      }
      if (externalUrl.value.length < 10) {
        notyf.error(`NFT externalUrl must be longer then 10 characters!`);
        return;
      }
      if (!imageUrl.value) {
        notyf.error(`Please enter a imageUrl to continue!`);
        return;
      }
      if (imageUrl.value.length < 10) {
        notyf.error(`NFT image Url must be longer then 10 characters!`);
        return;
      }

      try {
        const { ethereum } = window;
        if (ethereum) {
          const provider = new ethers.providers.Web3Provider(ethereum);
          const signer = provider.getSigner();
          /**
           *  @dev Note: Reset this once Contracts deployed or re-dployed
           */
          const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi.abi, signer);
          console.log('Talk to the wallet and pay gas fees', signer);

          let nftTxn = await contract.safeMint(
            signer,
            maxInvocations.value,
            royaltyPercentage.value,
            price.value, // salesTotal set to zero
            title.value,
            category.value,
            license.value,
            website.value,
            longDescription.value,
            preview.value,
            audioVideoType.value,
            audioVideoURL.value,
            resoultion.value,
            duration.value,
            size.value,
            createdAt.value
          );
          console.log('Mining NFT...please wait!');

          // The OpenZeppelin base ERC721 contract emits a Transfer event
          // when a token is issued. tx.wait() will wait until a block containing
          // our transaction has been mined and confirmed. The transaction receipt
          // contains events emitted while processing the transaction.
          const receipt = await nftTxn.wait();
          if (receipt.status === 1) {
            /**
             * @dev NOTE: Switch up these links once we go to Production
             * Currently set to use Polygon Mumbai Testnet
             */
            console.log(
              `NFT Minted, see transaction: https://mumbai.polygonscan.com/txs/${nftTxn.hash}`
            );
            notyf.success(
              `NFT has been created successfully, see transaction: https://mumbai.polygonscan.com/txshttps://rinkeby.etherscan.io/tx/${nftTxn.hash}`
            );
          }
          /* Reset our NFT Metadata Form Values */
          name.value = '';
          description.value = '';
          externalUrl.value = '';
          imageUrl.value = '';
          backgroundColor.value = 'ffffff';
          maxInvocations.value = null;
          royaltyPercentage.value = null;
          price.value = null;
          /* Reset our NFT Metadata Attributes Form Values */
          title.value = '';
          category.value = '';
          license.value = '';
          website.value = '';
          longDescription.value = '';
          preview.value = '';
          audioVideoType.value = '';
          audioVideoURL.value = '';
          resoultion.value = '';
          duration.value = '';
          size.value = '';
          createdAt.value = '';
        } else {
          notyf.error("Ethereum object doesn't exist!");
          console.log("Ethereum object doesn't exist!");
        }
      } catch (error) {
        console.log('error', error);
      }
    };

    /**
     * Switch Form Tab
     */
    const addNFTAttributesTab = () => {
      formTab.value = 'two';
    };
    /**
     * Switch Form Tab Back
     */
    const goBack = () => {
      formTab.value = 'one';
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
     */
    const uploadFileHandler = async (file) => {
      const result = await uploadBlob(file);
      finished.value++;
      const { error } = result;
      if (error && error instanceof Error) {
        notyf.error(error.message);
        return result;
      }
      /* Set our NFT Metadata Form Values */
      cid.value = result.data.cid;
      name.value = result.data.file.name.substring(0, result.data.file.name.lastIndexOf('.'));
      // description.value = '';
      // externalUrl.value = '';
      imageUrl.value = generateLink(result.data);
      // backgroundColor.value = 'ffffff';
      // maxInvocations.value = 1;
      // royaltyPercentage.value = 10;
      // price.value = 10;
      /* Reset our NFT Metadata Attributes Form Values */
      // title.value = '';
      // category.value = '';
      // license.value = '';
      // website.value = '';
      // longDescription.value = '';
      // preview.value = '';
      audioVideoType.value = result.data.file.type;
      // audioVideoURL.value = '';
      // resoultion.value = '';
      // duration.value = '';
      size.value = fileSize(result.data.file.size);
      createdAt.value = result.data.file.created_at;
      return result;
    };
    const onFileChangedHandler = async () => {
      isUploading.value = true;
      store.addFiles(...fileRef.value.files);
      const files = store.files.map((file) => uploadFileHandler(file));
      try {
        let results = await Promise.all(files);
        const successfully = results.filter(({ error }) => !error);
        console.log('successfully', successfully);
        if (successfully.length > 0) {
          notyf.success(`${successfully.length} files successfully uploaded to IPFS`);
        }
        if (successfully.length === 0) {
          notyf.error(`Oops! An error occurred while processing your files.`);
        }
        store.addResults(...successfully.map(({ error, data: file }) => file));
        store.resetFiles();
        fileRef.value.value = null;
      } catch (error) {
        // notyf.error(`Oops! an error while processing your files.`);
        console.log(error);
        finished.value = 0;
        isUploading.value = false;
      } finally {
        console.log('finally');
        finished.value = 0;
        isUploading.value = false;
      }
    };
    const fileCount = computed(() => {
      return store.files.length;
    });
    const result = computed(() => {
      return {
        count: store.results.length,
        size: store.results.reduce((sum, result) => {
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
      currentAccount,
      formTab,
      tokenId,
      cid,
      name,
      description,
      externalUrl,
      imageUrl,
      backgroundColor,
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
      resoultion,
      duration,
      size,
      createdAt,
      goBack,
      addNFTAttributesTab,
      mintNFT,
      updateNFT,
      generateLink,
      fileSize,
      onDragEnter,
      onDragLeave,
      onDropHandler,
      openSelectFile,
      onFileChangedHandler,
      checkIfWalletIsConnected,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../assets/styles/variables.scss';
@import '../assets/styles/mixins.scss';

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

    section#connect {
      height: 100%;
      color: #1a1a1a;
      background: #fff;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 10px;
      overflow: hidden;

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

        @include breakpoint($medium) {
          width: 60%;
        }

        .connect-message {
          max-width: 440px;
        }

        section#panel-upload {
          background-color: var(--gradient-100);
          border-top-left-radius: 1rem;
          border-top-right-radius: 1rem;
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
            cursor: pointer;
            overflow: hidden;

            display: flex;
            align-content: center;
            align-items: center;
            justify-content: center;

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
                font-size: 0.8rem;
              }
            }

            .dropzone-details {
              position: absolute;
              display: flex;
              bottom: 1rem;
              left: 1rem;

              .dropzone-detail {
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
                  content: '';
                  position: absolute;
                  background-color: inherit;
                  top: 0;
                  left: 0;
                  bottom: 0;
                  will-change: left, right;
                  animation: indeterminate 2.1s cubic-bezier(0.65, 0.815, 0.735, 0.395) infinite;
                }

                &:after {
                  content: '';
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

        @include breakpoint($medium) {
          width: 40%;
        }

        .form-container {
          display: flex;
          width: 99%;
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
          width: 300px;
          margin-bottom: 10px;
          padding: 10px;
          text-align: center;
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
          background-color: #550072;
          font-size: 18px;
          font-weight: bold;
          width: auto;
          height: 55px;
          border: 0;
          padding-left: 90px;
          padding-right: 90px;
          border-radius: 10px;
          cursor: pointer;
        }

        .attr-button:disabled {
          background: #c6c6c6;
          color: #101010;
          cursor: not-allowed;
        }

        .back-button {
          color: #08d0a5;
          background-color: #fff;
          font-size: 18px;
          font-weight: bold;
          width: auto;
          height: 55px;
          border: 2px solid #08d0a5;
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
          width: auto;
          height: 55px;
          border: 0;
          padding-left: 80px;
          padding-right: 80px;
          border-radius: 10px;
          cursor: pointer;
        }

        .mint-button:disabled {
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
          height: 55px;
          border: 0;
          padding-left: 68px;
          padding-right: 68px;
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
  section#content .main section#mint .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .mint {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
