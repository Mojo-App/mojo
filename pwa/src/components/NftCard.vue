<template>
  <div class="nft">
    <div v-if="token.metadata && token.metadata.image" class="nft-image">
      {{ getUrlProtocol(token.metadata.image) }}
      <img
        v-if="token.metadata.image"
        :src="`${token.metadata.image}`"
        :alt="`${token.metadata.name}`"
      />
    </div>
    <div v-if="token.metadata && token.metadata.name" class="nft-title">
      {{ token.metadata.name }}
    </div>
    <div v-if="token.metadata && token.metadata.description" class="nft-time">
      {{ token.metadata.description }}
    </div>
  </div>
</template>
<script>
/* Import our IPFS and NftStorage Services */
import { generateLink } from "../services/helpers";
/* LFG */
export default {
  name: "NftCard",
  props: ["token"],
  data() {
    return {
      playbackTime: 0,
      audioDuration: 100,
      listenerActive: false,
      audioLoaded: false,
      isPlaying: false,
    };
  },
  methods: {
    getUrlProtocol(url) {
      let protocol = url.startsWith("http://") ? 1 : 0;
      if (protocol == 0) protocol = url.startsWith("https://") ? 2 : 0;
      if (protocol == 0) protocol = url.startsWith("ipfs://") ? 3 : 0;
      if (protocol == 0) protocol = url !== "" ? 4 : 0;
      switch (protocol) {
        case 1:
          return url;
        case 2:
          return url;
        case 3:
          return "https://ipfs.io/ipfs/" + url;
        case 4:
          return generateLink(url);
        case 0:
          return "Not http or https";
      }
    },
  },
};
</script>
<style lang="scss">
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

.nft {
  display: block;
  box-sizing: border-box;
  position: relative;
  width: 100%;
  height: auto;
  background: #f4f4f4;
  border: 2px solid #f4f4f4;
  border-radius: 6px;
  overflow: hidden;
  float: center;
  margin: 0 auto 20px;

  @include breakpoint($breakpoint-sm) {
    float: left;
    margin: 0 10px 20px 10px;
  }

  @include breakpoint($breakpoint-md) {
    float: left;
    margin: 0 10px 20px 10px;
  }

  @include breakpoint($breakpoint-xl) {
    float: left;
    margin: 0 20px 20px 0;
  }

  &:hover {
    border: 2px solid #8d50f5;
  }

  .nft-image {
    display: flex;
    align-content: center;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 118px;
    background: #f4f4f4;
  }

  .nft-title {
    color: #1a1a1a;
    width: 100%;
    font-size: 11px;
    font-weight: normal;
    text-transform: uppercase;
    text-align: center;
  }
}

// .nft:nth-child(2n) {
//   margin: 0 0 20px 0;
//   @include breakpoint($medium) {
//     margin: 0 20px 20px 0;
//   }
// }

// .nft:nth-child(3n) {
//   margin: 0 20px 20px 0;
//   @include breakpoint($medium) {
//     margin: 0 20px 20px 0;
//     margin: 0 0 20px 0;
//   }
// }
</style>
