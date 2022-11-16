<template>
  <section id="content">
    <div class="main">
      <section id="home">
        <div class="left">
          <h1>Hear it, See it, Live it.</h1>
          <p>
            Stream audio, video &amp; media directly from your favourite artists and musicians on
            the blockchain. Subscribe and follow your favourite digital content creators for
            rewards. Purchase your Mojo Creators NFT to unlock additional content and so much
            more...
            <br />
            <br />
            <strong class="cool-text">Get your mojo on today!</strong>
          </p>
        </div>
        <div class="right">
          <div class="player-graphic">
            <img src="../assets/images/DJ.png" alt="DJ Saved my Life" />
          </div>
        </div>
      </section>
      <section id="stream-home">
        <div class="row-header">
          <h2 class="left"><span class="mint-black">fresh</span>beats</h2>
        </div>
        <div v-if="homeTokens && homeTokens.length > 0" class="row token-list">
          <template v-for="token in homeTokens" :key="token.token_id">
            <NftCard
              :contract="token.contract_address"
              :tokenId="token.token_id"
              :type="token.type"
              :name="
                token.metadata && token.metadata.name
                  ? token.metadata.name
                  : token.metadata && token.metadata.title
                  ? token.metadata.title
                  : ''
              "
              :image="
                token.cached_animation_url
                  ? token.cached_animation_url
                  : token.cached_file_url
                  ? token.cached_file_url
                  : token.image
                  ? token.image
                  : ''
              "
              :description="
                token.metadata && token.metadata.description ? token.metadata.description : ''
              "
              :external_url="
                token.metadata && token.metadata.external_url ? token.metadata.external_url : ''
              "
              :animation_url="
                token.metadata && token.metadata.animation_url ? token.metadata.animation_url : ''
              "
              :attributes="
                token.metadata && token.metadata.attributes ? token.metadata.attributes : []
              "
            />
          </template>
        </div>
      </section>
      <section id="connect">
        <div class="row">
          <div class="left">
            <button @click="$router.push('mint')" class="mint-media-button">connect</button>
            <p>
              Creating an NFT is very easy, once you've created your profile and connected your
              MetaMask wallet, just unleash your creativity and we'll take care of the rest. You
              will be able to associate to your NFT any digital file, even simultaneously: jpeg,
              wav, mp4, mov, mp3, gif, pdf, txt.
            </p>
          </div>
          <div class="right"></div>
        </div>
      </section>
      <section id="stream">
        <div class="row">
          <div class="left"></div>
          <div class="right">
            <button @click="$router.push('stream')" class="stream-button">stream</button>
            <p>
              You are worth much more than a number of views. Streaming has led to a quick and light
              consumption of music that doesn't return the proper value, both financial and
              emotional, to the artist. NFTs can give music back its true value and create deeper
              connections between artists and fans.
            </p>
          </div>
        </div>
      </section>
      <section id="upload">
        <div class="row">
          <div class="left">
            <button @click="$router.push('upload')" class="upload-button">upload</button>
            <p>
              Upload all your audio &amp; media files directly to the Interplanetary File System
              (IPFS) Network. Pin your data so it will never get deleted, edited or hacked and will
              never get saved to any server - <strong>100% decentralized</strong>.
            </p>
          </div>
          <div class="right"></div>
        </div>
      </section>
      <section id="sponsors">
        <div class="row">
          <div class="sponsors-logo">
            <Tableland />
          </div>
          <div class="sponsors-logo">
            <img alt="IPFS" src="@/assets/images/IPFS.png" height="38" />
          </div>
          <div class="sponsors-logo">
            <NFTStorage />
          </div>
          <div class="sponsors-logo">
            <PolygonLogo />
          </div>
        </div>
      </section>
      <!-- <section id="royalties">
        <div class="row">
          <div class="left">
            <h1>Royalties</h1>
            <h2>
              Support artists &amp; creators<br />
              <span class="yellow">directly with your streams</span>
            </h2>
            <p>
              Every time you click <span class="blue">Play</span>, our smart contracts<br
                class="hide-mobile"
              />
              pay artists and content creators directly
            </p>
          </div>
          <div class="right">
            <div class="royalty-graphic">
              <img src="../assets/images/RoyaltyFees.jpeg" alt="Royalty Fees" />
            </div>
          </div>
        </div>
      </section> -->
    </div>
  </section>
</template>
<script setup>
import { onMounted } from "vue";
import { Notyf } from "notyf";

/* Import our Pinia Store */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Components */
import NftCard from "@/components/NftCard.vue";

/* Logos */
import Tableland from "../assets/svgs/TableLand.vue";
import PolygonLogo from "../assets/svgs/PolygonLogo.vue";
import NFTStorage from "../assets/svgs/NFTStorage.vue";

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

/* Import our Pinia Store */
const store = useStore();
const { account, homeTokens } = storeToRefs(store);

/**
 * Check if Wallet connected
 */
async function checkIfWalletIsConnected() {
  try {
    /*
     * First make sure we have access to window.ethereum
     */
    const { ethereum } = window;
    if (!ethereum) {
      notyf.error(`⛽ Please connect MetaMask to continue!`);
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
/**
 * Fetch NFT Audio/Media data from opensea.io
 */
async function fetchData() {
  /* Load some cool NFTs using NFT Port */
  if (homeTokens.value.length === 0) {
    try {
      let homeTokens = await store.contractNftSearch(
        "0xefadc46bb78b01195a1e12c82a584caf5403585c",
        "ethereum",
        "metadata",
        "true",
        5,
        1
      );
      // console.log("Home NFTs 1:", JSON.stringify(homeTokens, "", 4));
      if (homeTokens.nfts) {
        store.addHomeTokens(...homeTokens.nfts);
      }
      let homeTokensRowTwo = await store.contractNftSearch(
        "0x719c6d392fc659f4fe9b0576cbc46e18939687a7",
        "ethereum",
        "metadata",
        "true",
        5,
        1
      );
      // console.log("Home NFTs 2:", JSON.stringify(homeTokensRowTwo, "", 4));
      if (homeTokensRowTwo.nfts) {
        store.addHomeTokens(...homeTokensRowTwo.nfts);
      }
    } catch (error) {
      console.log(error);
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
  await fetchData();
});
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#content {
  position: relative;
  height: auto;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#home {
      color: $white;
      background: $mojo-yellow;
      border-bottom: 1px solid $mojo-dark-blue;
      display: flex;
      flex-direction: row;
      align-content: center;
      align-items: center;
      justify-content: space-between;
      padding: 40px 20px;

      @include breakpoint($break-ssm) {
        flex-direction: column;
        justify-content: center;
        padding: 20px;
      }

      .left {
        width: 45%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        padding: 20px;
        @include breakpoint($break-ssm) {
          width: 100%;
        }
      }

      .right {
        width: 55%;
        display: flex;
        align-content: flex-start;
        justify-content: flex-start;
        flex-direction: column;
        padding: 20px;

        @include breakpoint($break-ssm) {
          width: 100%;
          align-content: center;
          justify-content: center;
        }
      }

      h1 {
        color: $mojo-dark-blue;
        font-size: 4.25rem;
        margin-bottom: 20px;
      }

      .cool-text {
        color: $mojo-dark-blue;
        font-size: 1.4rem;
        font-weight: 900;
        text-transform: uppercase;
      }

      a {
        color: var(--contrast-color);
        font-weight: bold;
        border-bottom: 1px solid var(--contrast-color);
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
        color: $mojo-dark-blue;
        line-height: 1.7;
        margin-bottom: 20px;
      }

      .player-graphic {
        width: 100%;
        margin: 0 auto;
        padding: 0;
        overflow: hidden;

        img,
        svg {
          width: 90%;
          object-fit: cover;
          overflow: hidden;
        }
      }
    }

    section#stream-home {
      color: $white;
      background: $mojo-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      margin: 0 auto;
      padding: 40px 40px 80px 40px;

      .row-header {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: flex-start;
        justify-content: center;
        align-items: center;
        margin: 0;

        h2 {
          width: 100%;
          color: $white;
          font-size: 34px;
          font-style: normal;
          font-weight: 700;
          line-height: 42px;
          padding-left: 20px;

          .left {
            text-align: left;
          }
          .right {
            text-align: right;
          }
          .mint-black {
            color: $black;
          }
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
        width: 100%;
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 30px;
        align-content: center;
        justify-content: center;
        align-items: flex-start;

        /* Tablet Landscape */
        @include breakpoint($break-md) {
          grid-template-columns: repeat(3, 1fr);
        }
        /* Tablet Portrait LG */
        @include breakpoint($break-sm) {
          grid-template-columns: repeat(3, 1fr);
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
      }
    }

    section#connect {
      color: $mojo-yellow;
      background: $mojo-dark-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 60px 40px;
      transition: 0.6s;

      @include breakpoint($break-md) {
        padding: 60px 20px 100px 20px;
      }

      @include breakpoint($break-sm) {
        padding: 10px 10px 0 10px;
      }

      &:hover {
        color: $mojo-dark-blue;
        background: $mojo-yellow;
      }

      .row {
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($break-ssm) {
          flex-direction: column;
        }

        .left {
          width: 65%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: flex;
          align-items: center;

          @include breakpoint($break-ssm) {
            width: 100%;
          }

          h2 {
            width: 100%;
            font-size: 34px;
            font-style: normal;
            font-weight: 700;
            line-height: 42px;
            text-align: center;
          }

          p {
            line-height: 1.7;
            margin: 0 auto 20px;
            text-align: center;
          }
          .mint-media-button {
            width: auto;
            color: $mojo-yellow;
            background-color: $mojo-dark-blue;
            font-size: 18px;
            font-weight: bold;
            max-width: 360px;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 60px;
            padding-right: 60px;
            margin-bottom: 15px;
            transition: 0.6s;
            cursor: pointer;

            &:hover {
              color: $mojo-blue;
            }
          }
        }

        .right {
          width: 35%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: center;
          align-items: flex-start;
          padding: 30px 0;

          @include breakpoint($break-ssm) {
            width: 100%;
            align-items: center;
          }
        }
      }
    }

    section#stream {
      color: $mojo-yellow;
      background: $mojo-dark-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 60px 40px;
      transition: 0.6s;

      &:hover {
        color: $mojo-dark-blue;
        background: $mojo-blue;
      }

      @include breakpoint($break-md) {
        padding: 60px 20px 100px 20px;
      }

      @include breakpoint($break-sm) {
        padding: 10px 10px 0 10px;
      }

      .row {
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($break-ssm) {
          flex-direction: column;
        }

        .left {
          width: 35%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: flex;
          align-items: center;

          @include breakpoint($break-ssm) {
            width: 100%;
          }
        }

        .right {
          width: 65%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: center;
          align-items: center;
          padding: 30px 0;

          @include breakpoint($break-ssm) {
            width: 100%;
            align-items: center;
          }

          h2 {
            width: 100%;
            font-size: 34px;
            font-style: normal;
            font-weight: 700;
            line-height: 42px;
            text-align: center;

            .mint-black {
              color: $black;
            }
          }

          p {
            line-height: 1.7;
            margin: 0 auto 20px;
            text-align: center;
          }

          .stream-button {
            width: auto;
            color: $mojo-blue;
            background-color: $mojo-dark-blue;
            font-size: 18px;
            font-weight: bold;
            max-width: 360px;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 60px;
            padding-right: 60px;
            margin-bottom: 15px;
            transition: 0.6s;
            cursor: pointer;

            &:hover {
              color: $mojo-yellow;
            }
          }
        }
      }
    }

    section#upload {
      color: $mojo-yellow;
      background: $mojo-dark-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 60px 40px;
      transition: 0.6s;

      &:hover {
        color: $mojo-dark-blue;
        background-color: $mojo-yellow;
      }

      @include breakpoint($break-md) {
        padding: 60px 20px 100px 20px;
      }

      @include breakpoint($break-sm) {
        padding: 10px 10px 0 10px;
      }

      .row {
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($break-ssm) {
          flex-direction: column;
        }

        .left {
          width: 65%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: flex;
          align-items: center;

          @include breakpoint($break-ssm) {
            width: 100%;
          }

          h2 {
            width: 100%;
            font-size: 34px;
            font-style: normal;
            font-weight: 700;
            line-height: 42px;
            text-align: center;
          }

          p {
            line-height: 1.7;
            margin: 0 auto 20px;
            text-align: center;
          }

          a {
            color: $mojo-dark-blue;
            font-weight: bold;
            border-bottom: 1px solid $mojo-dark-blue;
            text-decoration: none;
          }

          .upload-button {
            width: auto;
            color: $mojo-yellow;
            background-color: $mojo-dark-blue;
            font-size: 18px;
            font-weight: bold;
            max-width: 360px;
            height: 55px;
            border: 0;
            border-radius: 30px;
            padding-left: 60px;
            padding-right: 60px;
            margin-bottom: 15px;
            transition: 0.6s;
            cursor: pointer;

            &:hover {
              color: $mojo-blue;
            }
          }
        }

        .right {
          width: 35%;
          display: flex;
          flex-direction: column;
          align-content: center;
          justify-content: center;
          align-items: flex-start;
          padding: 30px 0;

          @include breakpoint($break-ssm) {
            width: 100%;
            align-items: center;
          }
        }
      }
    }

    section#royalties {
      color: #fff;
      background: $mojo-dark-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 0;

      .row {
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
        width: 50%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($break-ssm) {
          width: 100%;
        }
      }

      .right {
        width: 50%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($break-ssm) {
          width: 100%;
        }

        .royalty-graphic {
          width: 100%;
          margin: 0 auto;
          padding: 0;
          overflow: hidden;

          @include breakpoint($break-ssm) {
            padding: 0;
          }

          img,
          svg {
            width: 100%;
            height: 100%;
            object-fit: cover;
            overflow: hidden;
          }
        }
      }

      h1 {
        color: $mojo-blue;
        font-size: 2.85rem;
        text-align: center;
        margin-bottom: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
      }

      h2 {
        font-size: 34px;
        font-style: normal;
        font-weight: 700;
        line-height: 42px;
        text-align: center;
        margin-bottom: 5px;

        .yellow {
          font-size: 2.1rem;
          color: $mojo-yellow;
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
        max-width: 440px;
        line-height: 1.7;
        font-weight: 300;
        margin: 0 auto;
        text-align: center;

        .blue {
          font-size: 20px;
          font-weight: 500;
          text-decoration: underline;
          text-decoration-thickness: 1px;
          text-underline-offset: 2px;
          color: $mojo-blue;
        }
      }
    }

    section#sponsors {
      color: #000000;
      background: $mojo-dark-blue;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 20px;

      .row {
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($break-ssm) {
          flex-direction: column;
        }

        .sponsors-logo {
          margin: 10px 20px;
        }
      }

      h1 {
        color: $mojo-blue;
        font-size: 2.85rem;
        text-align: center;
        margin-bottom: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
      }

      h2 {
        font-size: 34px;
        font-style: normal;
        font-weight: 700;
        line-height: 42px;
        text-align: center;
        margin-bottom: 5px;

        .yellow {
          font-size: 2.1rem;
          color: #ffca28;
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
    }

    .hide-mobile {
      display: none;
    }

    .show-mobile {
      display: inline;
    }
  }
}

body.dark-theme {
  section#content .main section#home {
    border-bottom: 1px solid $mojo-dark-blue;
  }

  section#content .main section#home .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .home {
    min-height: $page-height;
    display: flex;
    align-items: center;
  }
}
</style>
