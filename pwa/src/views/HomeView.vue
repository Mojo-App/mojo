<template>
  <section id="content">
    <div class="main">
      <section id="home">
        <div class="left">
          <div class="player-graphic">
            <img src="../assets/images/DJ.png" alt="DJ Saved my Life" />
          </div>
        </div>
        <div class="right">
          <h1>Hear it, See it, Live it.</h1>
          <p>
            Stream audio, video &amp; media directly from your favorite content creators on the
            blockchain. Subscribe and follow your favorite digital artists and purchase your very
            own custom NFT. Get your Mojo on today to get access to additional content, rewards and
            so much more.
          </p>
        </div>
      </section>
      <section id="stream-home">
        <h2>Latest Tracks</h2>
        <div class="row">
          <TrackPlayer v-for="track in categoryTracks" :track="track" :key="track.id"></TrackPlayer>
        </div>
      </section>
      <section id="connect" class="multi-bg-header">
        <h2>Connect</h2>
        <div class="row">
          <div class="left">
            <p>
              Upload your audio/media files directly to the Interplanetary File System (<a
                href="https://infura.io/product/ipfs"
                target="_blank"
                rel="noopener"
                >IPFS</a
              >) Network. <br /><br />
              Pin your data so it will never get deleted, edited or hacked and will never get saved
              to any server so <strong>100% decentralized</strong>.<br /><br />
              Manage your NFT metadata with Tableland, add and edit additional NFT metadata
              attributes giving your NFT's' unique features, tailored to your audience.
            </p>
          </div>
          <div class="right">
            <ConnectWalletButton v-model="currentAccount" v-if="!currentAccount" btnSize="large" />
            <button @click="$router.push('stream')" v-if="currentAccount" className="stream-button">
              Let's Stream 🎶
            </button>
            <button @click="$router.push('upload')" v-if="currentAccount" className="upload-button">
              IPFS Upload 🎤
            </button>
            <button
              @click="$router.push('mint')"
              v-if="currentAccount"
              className="mint-media-button"
            >
              Get Minty 🧪
            </button>
          </div>
        </div>
      </section>
      <section id="sponsors">
        <div class="row">
          <div class="sponsors-logo">
            <PolygonLogo />
          </div>
          <div class="sponsors-logo">
            <SpheronLogo />
          </div>
          <div class="sponsors-logo">
            <Tableland />
          </div>
          <div class="sponsors-logo">
            <img alt="IPFS" src="@/assets/images/IPFS.png" height="38" />
          </div>
          <div class="sponsors-logo">
            <Metamask />
          </div>
        </div>
      </section>
      <section id="royalties">
        <div class="row">
          <div class="left">
            <h1>Royalties</h1>
            <h2>
              Support artists &amp; creators<br />
              <span class="yellow">directly with your streams</span>
            </h2>
            <p>
              Every time you click <span class="blue">Play</span>, our smart contracts<br />
              pay artists and content creators directly
            </p>
          </div>
          <div class="right">
            <div class="royalty-graphic">
              <img src="../assets/images/RoyaltyFees.jpeg" alt="Royalty Fees" />
            </div>
          </div>
        </div>
      </section>
    </div>
  </section>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import { Notyf } from 'notyf';
/* Components */
import ConnectWalletButton from '../components/ConnectWalletButton.vue';
import TrackPlayer from '../components/TrackPlayer.vue';
import Tableland from '../assets/svgs/TableLand.vue';
import SpheronLogo from '../assets/svgs/SpheronLogo.vue';
import PolygonLogo from '../assets/svgs/PolygonLogo.vue';
import Metamask from '../assets/svgs/Metamask.vue';
// Create an instance of Notyf
var notyf = new Notyf({
  duration: 2000,
  position: {
    x: 'center',
    y: 'bottom',
  },
  types: [
    {
      type: 'loading',
      background: 'orange',
      duration: 0,
      dismissible: true,
      icon: {
        className: 'icon icon-loading',
        tagName: 'i',
      },
    },
  ],
});

const currentAccount = ref('');
const categoryTracks = ref(null);
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
      notyf.error(`Please install Metamask to continue!`);
      console.log('Error: No Ethereum window object');
      return;
    }
    /* Get our Current Account */
    const accounts = await ethereum.request({ method: 'eth_accounts' });
    if (accounts.length !== 0) {
      currentAccount.value = accounts[0];
      console.log('Current Account: ', currentAccount.value);
    } else {
      console.log('No authorized Metamask accounts connected!');
    }
  } catch (error) {
    console.log(error);
  }
}

/**
 * Fetch NFT Audio/Media data
 * @dev This will change to pull our NFTs and their metadata from Tableland
 */
async function fetchData() {
  categoryTracks.value = null;
  const res = await fetch(`./tracks/1.json`);
  console.log('Tracks Loaded:', res);
  categoryTracks.value = await res.json();
}
fetchData();

onMounted(() => {
  checkIfWalletIsConnected();
  window.scrollTo({
    top: 0,
    left: 0,
    behavior: 'smooth',
  });
});
</script>

<style lang="scss" scoped>
@import '../assets/styles/variables.scss';
@import '../assets/styles/mixins.scss';

section#content {
  position: relative;
  height: auto;

  .main {
    width: 100%;
    height: 100%;
    margin: 0 auto;
    padding: 0;

    section#home {
      color: #212121;
      background: #ffca28;
      border-bottom: 1px solid #212121;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 20px;

      @include breakpoint($medium) {
        flex-direction: row;
        align-content: center;
        align-items: center;
        justify-content: space-between;
        padding: 40px 20px;
      }

      .left {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        padding: 0;

        @include breakpoint($medium) {
          width: 55%;
        }

        .player-graphic {
          width: 100%;
          margin: 0 auto;
          padding: 0 10px;
          overflow: hidden;

          @include breakpoint($medium) {
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

      .right {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        padding: 0 0 0 20px;

        @include breakpoint($medium) {
          width: 45%;
          align-content: flex-start;
          justify-content: flex-start;
          padding: 0 0 0 20px;
        }
      }

      h1 {
        font-size: 4.55rem;
        margin-bottom: 20px;
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
        line-height: 1.7;
        margin-bottom: 20px;
      }
    }

    section#stream-home {
      color: #fff;
      background: #1c8bfe;
      display: flex;
      flex-direction: column;
      align-content: center;
      align-items: center;
      justify-content: center;
      padding: 20px 0 0 20px;

      @include breakpoint($medium) {
        padding: 40px 0 0 120px;
      }
      @include breakpoint($large) {
        padding: 40px 0 0 0;
      }
      @include breakpoint($x3xl) {
        padding: 40px 0 0 0;
      }

      .row {
        width: 100%;
        display: inline-block;
        margin: 20px auto;
        @include breakpoint($medium) {
          max-width: 960px;
          margin: 40px auto;
        }
      }

      h2 {
        font-size: 2.45rem;
        margin: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
      }

      a {
        color: #1a1a1a;
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
        line-height: 1.7;
        margin-bottom: 20px;
      }

      ul.category-list {
        list-style-type: none;
        list-style-position: outside;
        margin-block-start: 1em;
        margin-block-end: 1em;
        margin-inline-start: 0px;
        margin-inline-end: 0px;
        padding-inline-start: 0;
        border-top: 1px solid #1a1a1a;

        li {
          font-size: 22px;
          font-weight: 700;
          line-height: 1.75rem;
          padding-top: 0.75rem;
          padding-bottom: 0.75rem;
          padding-left: 1rem;
          padding-right: 1rem;
          border-bottom: 1px solid #1a1a1a;

          &:hover {
            color: #fff;
            cursor: pointer;
          }

          &:active {
            color: #fff;
            font-weight: 600;
          }
        }
      }

      .li-active {
        color: #fff;
        font-weight: 600;
      }

      .category-list-play-button {
        margin: 0 5px 0 -15px;
      }
    }

    section#connect {
      color: #1a1a1a;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 30px 20px 50px 20px;

      @include breakpoint($medium) {
        padding: 60px 40px 100px 40px;
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

        .left {
          width: 100%;
          display: flex;
          flex-direction: row;
          align-content: center;
          justify-content: flex;
          align-items: center;

          @include breakpoint($medium) {
            width: 60%;
          }

          p {
            max-width: 520px;
            line-height: 1.7;
            margin: 0 auto;
            text-align: center;
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
        }
      }

      h2 {
        font-size: 2.85rem;
        text-align: center;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
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

    .multi-bg-header {
      background: #fff;
      background-image: url('./GreenCorner.png');
      background-repeat: no-repeat;
      background-position: center left;
      background-size: auto;
    }

    section#royalties {
      color: #fff;
      background: #000000;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 20px;

      @include breakpoint($medium) {
        padding: 20px;
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
        display: flex;
        flex-direction: column;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($medium) {
          width: 50%;
        }
      }

      .right {
        width: 100%;
        display: flex;
        flex-direction: row;
        align-content: center;
        justify-content: center;
        align-items: center;

        @include breakpoint($medium) {
          width: 50%;
        }

        .royalty-graphic {
          width: 100%;
          margin: 0 auto;
          padding: 0 10px;
          overflow: hidden;

          @include breakpoint($medium) {
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
        color: #2bb5f0;
        font-size: 2.85rem;
        text-align: center;
        margin-bottom: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
      }

      h2 {
        font-size: 2.2rem;
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
          color: #2bb5f0;
        }
      }
    }

    section#sponsors {
      color: #000000;
      background: #fff;
      display: flex;
      flex-direction: column;
      align-content: center;
      justify-content: center;
      padding: 20px;

      @include breakpoint($medium) {
        padding: 20px;
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

        .sponsors-logo {
          margin: 10px 20px;
        }
      }

      h1 {
        color: #2bb5f0;
        font-size: 2.85rem;
        text-align: center;
        margin-bottom: 0;
        text-decoration: underline;
        text-decoration-thickness: 2px;
        text-underline-offset: 4px;
      }

      h2 {
        font-size: 2.2rem;
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
  }
}

body.dark-theme {
  section#content .main section#home {
    border-bottom: 1px solid #ffffff;
  }

  section#content .main section#home .author {
    background-color: var(--gradient-800);
  }
}

@media (min-width: 1024px) {
  .home {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}
</style>
