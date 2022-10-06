<template>
  <header id="header">
    <div class="header-title">
      <router-link :to="{ name: 'home' }" active-class="active" exact
        ><img class="header-logo" alt="Mojo" src="@/assets/images/MojoLogo.png" height="60"
      /></router-link>
      <div class="slogan">
        <span class="blue-hover">beats</span><br />
        <span class="red-hover">&nbsp;&nbsp;on</span><br />
        <span class="purple-hover">&nbsp;&nbsp;&nbsp;&nbsp;blocks</span>
      </div>
    </div>
    <div class="header-menu">
      <nav class="header-navbar">
        <router-link :to="{ name: 'home' }" active-class="active" exact>home</router-link>
        <router-link :to="{ name: 'stream' }" active-class="active" exact>stream</router-link>

        <!-- NFT Holders / Members Only -->
        <router-link v-if="account" :to="{ name: 'explore' }" active-class="active" exact
          >explore</router-link
        >
        <router-link v-if="account" :to="{ name: 'upload' }" active-class="active" exact
          >upload</router-link
        >
        <router-link v-if="account" :to="{ name: 'mint' }" active-class="active" exact
          >mint</router-link
        >
        <router-link v-if="account" :to="{ name: 'collection' }" active-class="active" exact
          >collections</router-link
        >
        <!-- END NFT Holders / Members Only -->
        <div class="right">
          <ConnectWalletButton v-model="account" btnSize="small" />
        </div>
        <i :title="`Let's Jam ${isDark ? 'Light' : 'Dark'} Mode`">
          <i-mdi-brightness-7 v-if="isDark" class="icon-color" @click="toggleTheme" />
          <i-mdi-brightness-4 v-else class="icon-color" @click="toggleTheme" />
        </i>
      </nav>
    </div>
  </header>
</template>
<script>
import { ref, onMounted } from "vue";

/* Import our Pinia Store & Refs */
import { storeToRefs } from "pinia";
import { useStore } from "../store";

/* Components */
import ConnectWalletButton from "../components/ConnectWalletButton.vue";

/* LFG */
export default {
  name: "AppHeader",
  components: [ConnectWalletButton],
  setup() {
    /* Init Store */
    const store = useStore();
    const { account } = storeToRefs(store);

    /* Darth Vader Mode */
    const isDarkClassAvailable = document.body.classList.contains("dark-theme");
    const isDark = ref(isDarkClassAvailable);

    /**
     * Get our current 🦊 Metamask account details
     */
    const getCurrentAccount = async () => {
      try {
        /*
         * First make sure we have access to window.ethereum
         */
        const { ethereum } = window;
        if (!ethereum) return;
        /* Get our Current Account */
        const accounts = await ethereum.request({ method: "eth_accounts" });
        if (accounts.length !== 0) {
          store.updateAccount(accounts[0]);
          /* Console log with some style */
          const stylesAccounts = ["color: black", "background: cyan"].join(";");
          console.log("%c🧰 Web3 Account %s 🧰", stylesAccounts, account.value);
        } else {
          console.log("⚠ No authorized MetaMask accounts connected!");
        }
      } catch (error) {
        console.log(error);
      }
    };

    /**
     * Toggle our theme colors and animations
     */
    const toggleTheme = () => {
      document.body.classList.toggle("dark-theme");
      requestAnimationFrame(toggleAnimation);
      isDark.value = !isDark.value;
    };
    const toggleAnimation = () => {
      const element = document.querySelector("section#content .main");
      element.classList.remove("animated");
      void element.offsetWidth;
      element.classList.add("animated");
    };
    onMounted(() => {
      getCurrentAccount();
    });

    return {
      isDark,
      account,
      getCurrentAccount,
      toggleTheme,
    };
  },
};
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

#header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: border-bottom 0.5s ease;
  border-bottom: 1px solid #1a1a1a;
  padding: 0 64px 0 64px;

  .header-title {
    display: flex;
    justify-content: center;
    align-items: flex-end;

    .header-logo {
      border: 1px solid #000000;
      margin: 10px 10px 5px 0;
      border-radius: 50%;
    }
    .slogan {
      font-size: 1.1rem;
      font-weight: 500;
      margin: 0 0 8px 0;
      color: $white;
      transition: 0.4s;
      .blue-hover {
        &:hover {
          color: $mojo-blue;
        }
      }
      .red-hover {
        &:hover {
          color: $mojo-red;
        }
      }
      .purple-hover {
        &:hover {
          color: $mojo-purple;
        }
      }
    }
  }

  .header-menu {
    display: flex;
    align-items: center;

    nav {
      display: flex;
      align-items: center;
      text-align: right;

      a {
        color: var(--contrast-color);
        margin-right: 16px;
        padding-bottom: 2px;
        text-decoration: none;
        border-bottom: 1px solid;
        transition: 0.4s;
        cursor: pointer;

        &:hover {
          color: $mojo-blue;
          font-weight: bold;
        }
        &.active {
          color: $mojo-blue;
          font-weight: bold;
        }
      }

      svg {
        cursor: pointer;
        font-size: 2em;
      }
    }
  }
}

body.dark-theme {
  #header {
    border-bottom: 1px solid #ffffff;

    .header-title h1 {
      color: #ffffff;
    }

    .header-logo {
      border: 1px solid #ffffff;
    }
  }
}
</style>
