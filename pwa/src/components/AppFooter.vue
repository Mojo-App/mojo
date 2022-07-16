<template>
  <footer id="footer">
    <div class="footer-title">
      <span
        >Web3 content streaming powered by
        <a href="https://infura.io/product/ipfs" alt="IPFS" target="_blank" rel="noopener">IPFS</a>
        and
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
          >HackFS</a
        >
        <a href="https://github.com/Mojo-App" alt="GitHub" target="_blank" rel="noopener">GitHub</a>
        <a href="https://twitter.com/webmoss" alt="Twitter" target="_blank" rel="noopener"
          >Twitter</a
        >
        <a
          href="https://www.linkedin.com/in/craig-moss-21822628/"
          alt="LinkedIn"
          target="_blank"
          rel="noopener"
          >LinkedIn</a
        >
      </nav>
    </div>
  </footer>
</template>
<script>
export default {
  name: 'AppFooter',
};
</script>
<style lang="scss">
@import '../assets/styles/variables.scss';
@import '../assets/styles/mixins.scss';

#footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: border-top 0.5s ease;
  border-top: 1px solid #000000;
  padding: 1em 64px;

  color: #000000;
  background: #fff;
  border-top: 1px solid #000000;

  .footer-title {
    padding-left: 30px;
    @include breakpoint($medium) {
      padding-left: 100px;
    }
    span {
      font-size: 0.8rem;
      a {
        font-size: 0.8rem;
        color: var(--contrast-color);
        padding-bottom: 1px;
        text-decoration: none;
        border-bottom: 1px solid;
        cursor: pointer;
        &.active {
          font-weight: bold;
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
      justify-content: center;
      padding: 0.3em;
      @include breakpoint($medium) {
        justify-content: flex-end;
      }

      a {
        font-size: 0.8rem;
        color: var(--contrast-color);
        margin-right: 14px;
        padding-bottom: 1px;
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
  #footer {
    color: #fff;
    background: #000000;
    border-top: 1px solid #1a1a1a;

    .footer-title h1 {
      color: #ffffff;
    }
  }
}
</style>
