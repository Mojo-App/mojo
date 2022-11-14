<template>
  <section id="content">
    <div class="main">
      <div class="main-content">
        <PanelUpload />
        <PanelResult />
      </div>
    </div>
  </section>
</template>
<script>
import { provide } from "vue";
import { Notyf } from "notyf";
/* Components */
import PanelUpload from "../components/VUpload/PanelUpload.vue";
import PanelResult from "../components/VUpload/PanelResult.vue";
/* LFG */
export default {
  name: "UploadView",
  components: {
    PanelUpload,
    PanelResult,
  },
  setup() {
    const NotfyProvider = new Notyf({
      duration: 2000,
      position: {
        x: "center",
        y: "bottom",
      },
      types: [
        {
          type: "loading",
          background: "orange",
          duration: 0,
          dismissible: true,
          icon: {
            className: "icon icon-loading",
            tagName: "i",
          },
        },
      ],
    });
    provide("notyf", NotfyProvider);
  },
};
</script>
<style lang="scss" scoped>
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

section#content {
  position: relative;
  height: 100%;
  overflow: hidden;

  .bg-shape {
    background: #fff;
    background-image: url("./BlackCorner.png");
    background-repeat: no-repeat;
    background-position: center right;
    background-size: auto;
  }

  .main {
    display: flex;
    align-content: center;
    align-items: center;
    justify-content: center;
    height: 99%;
    color: #1a1a1a;
    background: $mojo-blue;
    padding: 20px 10px 40px 10px;
    overflow: scroll;

    .main-content {
      position: absolute;
      z-index: 3;
      display: flex;
      border-radius: 1em;
      box-shadow: 2px 2px 25px 6px rgba(43, 43, 43, 0.1);

      section {
        color: #fff;
        width: auto;
        height: 660px;
      }
    }
  }
}
</style>
