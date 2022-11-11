<template>
  <div class="nft">
    <div v-if="image && getUrlProtocol(image) === 'mp4'" class="nft-video">
      <video height="240" controls>
        <source :src="`${image}`" type="video/mp4" />
        <!-- <source :src="`${token.metadata.image}`" type="video/ogg" /> -->
        Your browser does not support the video tag.
      </video>
    </div>
    <div v-else-if="image && getUrlProtocol(image) === 'mp3'" class="nft-video">
      <video height="240" controls>
        <source :src="getUrlProtocol(image)" type="video/mp3" />
        <!-- <source :src="`${image}`" type="video/ogg" /> -->
        Your browser does not support the video tag.
      </video>
    </div>
    <div v-else-if="image" class="nft-image">
      <img :src="`${getUrlProtocol(image)}`" :alt="`${name}`" />
    </div>
    <div v-else class="nft-error-image">
      <img src="../assets/images/ImageError.png" alt="No image" />
    </div>
    <!-- <div v-if="contract" class="nft-title">Contract : {{ contract }}</div> -->
    <!-- <div v-if="tokenId" class="nft-title">Token Id : {{ tokenId }}</div> -->
    <div v-if="name" class="nft-title">
      {{ name }}
    </div>
    <div v-else class="nft-title">Nameless</div>
    <!-- <div v-if="description" class="nft-description">
      {{ description }}
    </div>
    <div v-if="external_url" class="nft-external-url">
      {{ external_url }}
    </div>
    <div v-if="animation_url" class="nft-animation-url">
      {{ animation_url }}
    </div>
    <div v-if="attributes" class="nft-attributes">
      <template v-for="attr in attributes" :key="attr.value">
        <div class="nft-attribute-cards">
          <div class="nft-attribute-card">
            <div class="nft-attribute-card-trait">{{ attr.trait_type }} : {{ attr.value }}</div>
          </div>
        </div>
      </template>
    </div> -->
  </div>
</template>
<script>
/* Import our IPFS and NftStorage Services */
import { generateLink } from "../services/helpers";
/* LFG */
export default {
  name: "NftCard",
  props: [
    "contract",
    "tokenId",
    "type",
    "name",
    "image",
    "description",
    "external_url",
    "animation_url",
    "attributes",
  ],
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
      let protocol = url.endsWith("mp4") ? 5 : 0;
      if (protocol == 0) protocol = url.startsWith("http://") ? 1 : 0;
      if (protocol == 0) protocol = url.startsWith("https://") ? 2 : 0;
      if (protocol == 0) protocol = url.startsWith("ipfs://") ? 3 : 0;
      if (protocol == 0) protocol = url !== "" ? 4 : 0;
      switch (protocol) {
        case 1:
          return url;
        case 2:
          return url;
        case 3:
          return "https://ipfs.io/ipfs/" + url.substring(7);
        case 4:
          return generateLink(url);
        case 5:
          return "mp4";
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
  width: 100%;
  min-height: 260px;
  background: #f4f4f4;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;

  .nft-video {
    width: 100%;
    margin: 0 auto;
    padding: 0;
    overflow: hidden;
    background: #f4f4f4;

    video {
      width: 100%;
      height: 100%;
      object-fit: contain;
      overflow: hidden;
    }
  }

  .nft-image {
    width: 100%;
    margin: 0 auto;
    padding: 0;
    overflow: hidden;

    img,
    svg {
      width: 100%;
      height: 100%;
      object-fit: contain;
      overflow: hidden;
    }
  }

  .nft-error-image {
    width: 100%;
    margin: 15px auto 0;
    padding: 0;
    overflow: hidden;

    img,
    svg {
      width: 100%;
      height: 100%;
      object-fit: contain;
      overflow: hidden;
    }
  }

  .nft-title {
    color: #1a1a1a;
    width: 100%;
    font-size: 14px;
    font-weight: normal;
    text-transform: uppercase;
    text-align: center;
    margin: 20px 0;
  }

  .nft-description {
    color: #1a1a1a;
    width: 100%;
    font-size: 14px;
    font-weight: normal;
    text-transform: uppercase;
    text-align: center;
    margin: 20px 0;
  }

  .nft-external-url {
    color: #1a1a1a;
    width: 100%;
    font-size: 14px;
    font-weight: normal;
    text-transform: uppercase;
    text-align: center;
    margin: 20px 0;
  }

  .nft-animation-url {
    color: #1a1a1a;
    width: 100%;
    font-size: 14px;
    font-weight: normal;
    text-transform: uppercase;
    text-align: center;
    margin: 20px 0;
  }
  .nft-attributes {
    color: #1a1a1a;
    width: 100%;
    font-size: 14px;
    font-weight: normal;
    text-align: center;
    margin: 10px auto 0;
    display: flex;
    flex-direction: row wrap;
    align-content: flex-start;
    justify-content: space-between;
    align-items: flex-start;
    overflow: scroll;

    .nft-attribute-card {
      width: auto;
      min-width: 60px;
      min-height: 40px;
      color: $black;
      background-color: #fff;
      border: 1px solid $mojo-blue;
      border-radius: 10px;
      letter-spacing: 1px;
      font-size: 12px;
      line-height: 20px;
      margin: 0 5px 5px 5px;
      padding: 10px;
      text-align: left;

      .nft-attribute-card-trait {
        display: flex;
        flex-direction: row wrap;
        align-content: flex-start;
        justify-content: space-between;
        align-items: flex-start;
      }
    }
  }
}
</style>
