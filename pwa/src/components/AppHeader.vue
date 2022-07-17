<template>
  <header id="header">
    <div class="header-title">
      <h1><span class="emoji">🎧</span> Mojo</h1>
    </div>
    <div class="header-menu">
      <nav class="header-navbar">
        <router-link :to="{ name: 'home' }" active-class="active" exact>Home</router-link>
        <router-link :to="{ name: 'stream' }" active-class="active" exact>Stream</router-link>
        <router-link v-if="account" :to="{ name: 'mint' }" active-class="active" exact
          >Mint</router-link
        >
        <router-link v-if="account" :to="{ name: 'upload' }" active-class="active" exact
          >Upload</router-link
        >
        <div v-if="!account" class="right">
          <ConnectWalletButton v-model="account" v-if="!account" btnSize="small" />
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
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';
/* Import Store */
import { useStore } from '../store';
/* Components */
import ConnectWalletButton from '../components/ConnectWalletButton.vue';
/* LFG */
export default {
  name: 'AppHeader',
  components: [ConnectWalletButton],
  setup() {
    // Init Store
    const store = useStore();
    const { account } = storeToRefs(store);
    // Darth Vader Mode
    const isDarkClassAvailable = document.body.classList.contains('dark-theme');
    const isDark = ref(isDarkClassAvailable);
    /**
     * Get our current Metamask account details
     */
    const getCurrentAccount = async () => {
      try {
        /*
         * First make sure we have access to window.ethereum
         */
        const { ethereum } = window;
        if (!ethereum) return;
        /* Get our Current Account */
        const accounts = await ethereum.request({ method: 'eth_accounts' });
        if (accounts.length !== 0) {
          store.updateAccount(accounts[0]);
          /* Console log with some style */
          const stylesAccounts = ['color: black', 'background: cyan'].join(';');
          console.log('%c🧰 Web3 Account %s 🧰', stylesAccounts, account.value);
        } else {
          console.log('⚠ No authorized MetaMask accounts connected!');
        }
      } catch (error) {
        console.log(error);
      }
    };
    /**
     * Toggle our theme colors and Animations
     */
    const toggleTheme = () => {
      document.body.classList.toggle('dark-theme');
      requestAnimationFrame(toggleAnimation);
      isDark.value = !isDark.value;
    };
    const toggleAnimation = () => {
      const element = document.querySelector('section#content .main');
      element.classList.remove('animated');
      void element.offsetWidth;
      element.classList.add('animated');
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
<style lang="scss">
#header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: border-bottom 0.5s ease;
  border-bottom: 1px solid #1a1a1a;
  padding: 1em 64px 0.8em 64px;

  .header-title {
    h1 {
      font-family: 'Ubuntu Mono', Roboto, Ubuntu, 'Open Sans', 'Helvetica Neue', sans-serif;
      font-size: 2.3rem;
      font-weight: 700;
      margin: 0 0 8px 0;
      color: #333;

      span.emoji {
        font-size: 1.8rem;
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
      padding: 0.3em;

      a {
        color: var(--contrast-color);
        margin-right: 16px;
        padding-bottom: 8px;
        text-decoration: none;

        border-bottom: 1px solid;
        cursor: pointer;

        &.active {
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
  }
}
</style>
