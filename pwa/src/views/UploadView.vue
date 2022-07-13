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
import { provide } from 'vue';
import { Notyf } from 'notyf';
/* Components */
import PanelUpload from '../components/VUpload/PanelUpload.vue';
import PanelResult from '../components/VUpload/PanelResult.vue';
/* LFG */
export default {
  name: 'UploadView',
  components: {
    PanelUpload,
    PanelResult,
  },
  setup() {
    const NotfyProvider = new Notyf({
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
    provide('notyf', NotfyProvider);
  },
};
</script>
<style lang="scss" scoped>
section#content {
  position: relative;
  height: 100%;

  .main {
    display: flex;
    align-content: center;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: #1a1a1a;
    background: #ffca28;

    .main-content {
      position: absolute;
      z-index: 3;
      display: flex;
      border-radius: 1em;
      overflow: hidden;

      section {
        width: 600px;
        height: 620px;
        color: #fff;
      }
    }
  }
}
</style>
