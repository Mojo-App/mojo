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

  .main {
    display: flex;
    align-content: center;
    align-items: center;
    justify-content: center;
    height: 99%;
    color: #1a1a1a;
    background: $mojo-purple;
    padding: 1% 10px 0 10px;
    overflow: hidden;

    .main-content {
      position: absolute;
      z-index: 3;
      display: flex;
      border-radius: 0.8em;

      section {
        color: #fff;
        width: 100%;
        height: 360px;

        @include breakpoint($breakpoint-sm) {
          width: 400px;
          height: 500px;
        }
        @include breakpoint($breakpoint-md) {
          width: 500px;
          height: 600px;
        }
        @include breakpoint($breakpoint-xl) {
          width: 600px;
          height: 600px;
        }
        @include breakpoint($x3xl) {
          width: 600px;
          height: 600px;
        }
      }
    }
  }
}
</style>
