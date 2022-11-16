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
      <div class="mobile-connect">
        <ConnectWalletButton v-model="account" btnSize="small" />
      </div>
    </div>
    <div class="header-menu">
      <nav class="header-navbar">
        <router-link :to="{ name: 'home' }" active-class="active" exact>home</router-link>
        <router-link :to="{ name: 'stream' }" active-class="active" exact>stream</router-link>

        <!-- NFT Holders / Members Only -->
        <router-link :to="{ name: 'explore' }" active-class="active" exact>explore</router-link>
        <router-link :to="{ name: 'upload' }" active-class="active" exact>upload</router-link>
        <router-link :to="{ name: 'collection' }" active-class="active" exact
          >collections</router-link
        >
        <router-link :to="{ name: 'mint' }" active-class="active" exact>mint</router-link>
        <!-- END NFT Holders / Members Only -->
        <div class="right">
          <ConnectWalletButton v-model="account" btnSize="small" />
        </div>
        <i class="toggle-icon" :title="`Let's Jam ${isDark ? 'Light' : 'Dark'} Mode`">
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
  border-bottom: 0.5px solid $mojo-dark-blue;
  padding: 0 44px;

  @include breakpoint($break-ssm) {
    padding: 0;
    border-bottom: none;
    flex-direction: column;
  }

  .header-title {
    display: flex;
    justify-content: center;
    align-items: flex-end;

    @include breakpoint($break-md) {
      width: 98%;
      justify-content: flex-start;
      align-items: center;
      padding-left: 2%;
    }
    @include breakpoint($break-ssm) {
      width: 98%;
      justify-content: flex-start;
      align-items: center;
      padding-left: 2%;
    }
    @include breakpoint($break-ssm) {
      width: 100%;
      justify-content: flex-start;
      align-items: center;

      h1 {
        font-size: 1.5em;
      }

      span {
        font-size: 0.8em;
      }
    }

    .header-logo {
      border: 2px solid $mojo-blue;
      margin: 10px 10px 5px 0;
      border-radius: 50%;
    }

    .slogan {
      font-size: 1.1rem;
      font-weight: 500;
      margin: 0 0 8px 0;
      color: $black;
      transition: 0.6s;

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
    .mobile-connect {
      display: none;
      @include breakpoint($break-sm) {
        display: inline;
        flex: 1;
        display: flex;
        justify-content: flex-end;
      }
      @include breakpoint($break-ssm) {
        display: inline;
        flex: 1;
        display: flex;
        justify-content: flex-end;
      }
    }
  }

  .header-menu {
    width: 100%;
    display: flex;
    flex-direction: row;
    align-content: center;
    justify-content: center;
    align-items: center;

    @include breakpoint($break-ssm) {
      width: 100%;
      height: auto;
      flex-direction: row wrap;
    }

    nav {
      width: 100%;
      display: flex;
      flex-direction: row;
      align-content: center;
      justify-content: flex-end;
      align-items: flex-end;

      @include breakpoint($break-ssm) {
        text-align: left;
        padding: 0 8px 6px;
        height: auto;
        justify-content: center;
        align-items: center;
      }

      a {
        color: var(--contrast-color);
        margin-right: 16px;
        padding-bottom: 2px;
        text-decoration: none;
        border-bottom: 1px solid;
        transition: 0.6s;
        cursor: pointer;

        &:hover {
          border-bottom: 1px solid $mojo-yellow;
          font-weight: bold;
        }

        &:focus {
          border-bottom: 1px solid $mojo-yellow;
          font-weight: bold;
        }

        &:active {
          border-bottom: 1px solid $mojo-yellow;
          font-weight: bold;
        }
      }

      @include breakpoint($break-ssm) {
        > a {
          font-size: 0.8em;
          margin-right: 11px;

          flex: row;
          display: flex;
          justify-content: center;

          &.active {
            font-weight: bold;
          }
        }

        .right {
          // flex: 1;
          // display: flex;
          // justify-content: flex-end;
          @include breakpoint($break-sm) {
            display: none;
          }
          @include breakpoint($break-ssm) {
            display: none;
          }
        }

        > i {
          display: flex;
          justify-content: flex-end;
        }
      }

      .toggle-icon {
        svg {
          cursor: pointer;
          font-size: 1.6em;
        }

        @include breakpoint($break-xs) {
          display: none;
        }
      }

      @include breakpoint($break-ssm) {
        .icon.icon-lg {
          position: fixed;
          top: 1em;
          right: 1em;
        }
      }
    }
  }
}

body.dark-theme {
  #header {
    background: $mojo-dark-blue;
    border-bottom: 0.5px solid #ffffff;

    .header-title h1 {
      color: #ffffff;
    }

    .header-logo {
      border: 2px solid $mojo-blue;
    }

    .slogan {
      font-size: 1.1rem;
      font-weight: 500;
      margin: 0 0 8px 0;
      color: $white;
      transition: 0.6s;

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
}
</style>
