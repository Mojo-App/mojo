<template>
  <footer id="footer">
    <div class="footer-title">
      <span
        >web3 content streaming powered by
        <a href="https://infura.io/product/ipfs" alt="IPFS" target="_blank" rel="noopener">IPFS</a>
        &amp;
        <a href="https://filecoin.io/" alt="Filecoin" target="_blank" rel="noopener"
          >Filecoin</a
        ></span
      >
    </div>
    <div class="footer-menu">
      <nav class="footer-navbar">
        <a
          href="https://ethglobal.com/showcase/mojo-11hkx"
          alt="HackFS"
          target="_blank"
          rel="noopener"
          >hackFS</a
        >
        <a href="https://github.com/Mojo-App" alt="GitHub" target="_blank" rel="noopener">github</a>
        <a href="https://twitter.com/MojoMusicNFT" alt="Twitter" target="_blank" rel="noopener"
          >twitter</a
        >
      </nav>
    </div>
  </footer>
</template>
<script>
export default {
  name: "AppFooter",
};
</script>
<style lang="scss">
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

#footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: border-top 0.5s ease;
  border-top: 0.5px solid #000000;
  padding: 1em 44px;

  @include breakpoint($break-ssm) {
    padding: 10px 0;
  }

  color: #000000;
  background: #fff;
  border-top: 1px solid #000000;

  .footer-title {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    padding: 0.3em;
    font-size: 0.8rem;
    @include breakpoint($break-ssm) {
      padding: 1em 0 0 0;
      font-size: 0.7rem;
      justify-content: center;
    }

    span {
      font-size: 0.8rem;
      @include breakpoint($break-ssm) {
        font-size: 0.6rem;
      }
      a {
        font-size: 0.8rem;
        color: var(--contrast-color);
        padding-bottom: 1px;
        text-decoration: none;
        border-bottom: 0.5px solid;
        cursor: pointer;
        @include breakpoint($break-ssm) {
          font-size: 0.6rem;
        }
        &:hover {
          font-weight: bold;
          border-bottom: 0.5px solid $mojo-light-blue;
        }
        &:focus {
          border-bottom: 0.5px solid $mojo-light-blue;
        }
      }
    }
  }

  .footer-menu {
    display: flex;
    align-items: center;

    .footer-navbar {
      display: flex;
      align-items: center;
      justify-content: flex-end;
      margin: 0;
      padding: 0.3em;
      font-size: 0.8rem;
      @include breakpoint($break-ssm) {
        padding: 0;
        font-size: 0.8rem;
        justify-content: center;
      }

      a {
        font-size: 0.8rem;
        color: var(--contrast-color);
        margin-right: 14px;
        padding-bottom: 1px;
        text-decoration: none;
        border-bottom: 0.5px solid;
        transition: 0.4s;
        cursor: pointer;
        @include breakpoint($break-ssm) {
          font-size: 0.6rem;
        }
        &:hover {
          font-weight: bold;
          border-bottom: 0.5px solid $mojo-light-blue;
        }
        &:focus {
          border-bottom: 0.5px solid $mojo-light-blue;
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
  #footer {
    color: #fff;
    background: #000000;
    border-top: 0.5px solid #ffffff;

    .footer-title h1 {
      color: #ffffff;
    }
  }
}
</style>
