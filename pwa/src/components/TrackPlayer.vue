<template>
  <div class="track">
    <div class="track-player">
      <div id="audio-player-root" class="track-player-box">
        <!-- Hide the default audio player -->
        <audio ref="player" :id="track.id" style="display: none">
          <source :src="track.url" type="audio/mpeg" />
        </audio>
        <PlayButton @click="toggleAudioPlay(track)" v-show="!isPlaying" />
        <PauseButton @click="toggleAudioPause()" v-show="isPlaying" />
      </div>
    </div>
    <div class="track-title">
      {{ track.title }}
    </div>
    <div class="track-time">
      <input
        v-model="playbackTime"
        type="range"
        min="0"
        :max="audioDuration"
        id="position"
        name="position"
      />
    </div>
  </div>
</template>
<script>
/* Components */
import PlayButton from "./icons/PlayButton.vue";
import PauseButton from "./icons/PauseButton.vue";
/* LFG */
export default {
  name: "TrackPlayer",
  props: ["track"],
  /**
   * playbackTime = local var that syncs to audio.currentTime
   * audioDuration = duration of audio file in seconds
   * isPlaying = boolean (true if audio is playing)
   *
   **/
  data() {
    return {
      playbackTime: 0,
      audioDuration: 100,
      listenerActive: false,
      audioLoaded: false,
      isPlaying: false,
    };
  },
  components: {
    PlayButton,
    PauseButton,
  },
  methods: {
    toggleAudioPlay(track) {
      var audios = document.getElementsByTagName("audio");
      for (var i = 0, len = audios.length; i < len; i++) {
        if (audios[i] != track.id) {
          audios[i].pause();
        }
      }
      var audio = this.$refs.player;
      if (audio.paused) {
        audio.play();
        this.isPlaying = true;
      } else {
        audio.pause();
        this.isPlaying = false;
      }
    },
    toggleAudioPause() {
      var audio = this.$refs.player;
      if (audio.paused) {
        audio.play();
        this.isPlaying = true;
      } else {
        audio.pause();
        this.isPlaying = false;
      }
    },
    // Set the range slider max value equal to audio duration
    initSlider() {
      var audio = this.$refs.player;
      if (audio) {
        this.audioDuration = Math.round(audio.duration);
      }
    },
    // Convert audio current time from seconds to min:sec display
    convertTime(seconds) {
      const format = (val) => `0${Math.floor(val)}`.slice(-2);
      // var hours = seconds / 3600;
      var minutes = (seconds % 3600) / 60;
      return [minutes, seconds % 60].map(format).join(":");
    },
    // Show the total duration of audio file
    totalTime() {
      var audio = this.$refs.player;
      if (audio) {
        var seconds = audio.duration;
        return this.convertTime(seconds);
      } else {
        return "00:00";
      }
    },
    // Display the audio time elapsed so far
    elapsedTime() {
      var audio = this.$refs.player;
      if (audio) {
        var seconds = audio.currentTime;
        return this.convertTime(seconds);
      } else {
        return "00:00";
      }
    },
    // Playback listener function runs every 100ms while audio is playing
    playbackListener() {
      var audio = this.$refs.player;
      // Sync local 'playbackTime' var to audio.currentTime and update global state
      this.playbackTime = audio.currentTime;
      // Add listeners for audio pause and audio end events
      audio.addEventListener("ended", this.endListener);
      audio.addEventListener("pause", this.pauseListener);
    },
    // Function to run when audio is paused by user
    pauseListener() {
      this.isPlaying = false;
      this.listenerActive = false;
      this.cleanupListeners();
    },
    // Function to run when audio play reaches the end of file
    endListener() {
      this.isPlaying = false;
      this.listenerActive = false;
      this.cleanupListeners();
    },
    // Remove listeners after audio play stops
    cleanupListeners() {
      var audio = this.$refs.player;
      audio.removeEventListener("timeupdate", this.playbackListener);
      audio.removeEventListener("ended", this.endListener);
      audio.removeEventListener("pause", this.pauseListener);
    },
  },
  mounted: function () {
    // nextTick code will run only after the entire view has been rendered
    this.$nextTick(function () {
      var audio = this.$refs.player;
      // Wait for audio to load, then run initSlider() to get audio duration and set the max value of our slider
      // "loademetadata" Event https://www.w3schools.com/tags/av_event_loadedmetadata.asp
      audio.addEventListener(
        "loadedmetadata",
        function () {
          this.initSlider();
        }.bind(this)
      );

      // "canplay" HTML Event lets us know audio is ready for play https://www.w3schools.com/tags/av_event_canplay.asp
      audio.addEventListener(
        "canplay",
        function () {
          this.audioLoaded = true;
        }.bind(this)
      );

      // Wait for audio to begin play, then start playback listener function
      this.$watch("isPlaying", function () {
        if (this.isPlaying) {
          var audio = this.$refs.player;
          this.initSlider();
          // Prevent starting multiple listeners at the same time
          if (!this.listenerActive) {
            this.listenerActive = true;
            // for a more consistent timeupdate, include freqtimeupdate.js and replace both instances of 'timeupdate' with 'freqtimeupdate'
            audio.addEventListener("timeupdate", this.playbackListener);
          }
        }
      });

      // Update current audio position when user drags progress slider
      this.$watch("playbackTime", function () {
        // var audio = this.$refs.player;
        var diff = Math.abs(this.playbackTime - this.$refs.player.currentTime);
        // Throttle synchronization to prevent infinite loop between playback listener and this watcher
        if (diff > 0.01) {
          this.$refs.player.currentTime = this.playbackTime;
        }
      });
    });
  },
};
</script>
<style lang="scss">
@import "../assets/styles/variables.scss";
@import "../assets/styles/mixins.scss";

.track {
  display: block;
  box-sizing: border-box;
  position: relative;
  width: 300px;
  height: 180px;
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

  .track-player {
    display: flex;
    align-content: center;
    justify-content: center;
    align-items: center;
    width: 100%;
    height: 118px;
    background: #f4f4f4;
  }

  .track-player-box {
    display: flex;
    cursor: pointer;
    margin: 0 auto;
    padding-top: 5px;
  }

  .track-title {
    color: #1a1a1a;
    width: 100%;
    font-size: 11px;
    font-weight: normal;
    text-transform: uppercase;
    text-align: center;
  }

  .track-time {
    position: absolute;
    bottom: 0;
    left: -22px;
    right: -30px;
    width: 114%;
    height: 18px;
    padding: 0;
    display: flex;
    overflow: hidden;

    .slider {
      width: 100%;
      height: 18px;
      margin-bottom: -12px;
      overflow: hidden;
    }
  }
}

// .track:nth-child(2n) {
//   margin: 0 0 20px 0;
//   @include breakpoint($medium) {
//     margin: 0 20px 20px 0;
//   }
// }

// .track:nth-child(3n) {
//   margin: 0 20px 20px 0;
//   @include breakpoint($medium) {
//     margin: 0 20px 20px 0;
//     margin: 0 0 20px 0;
//   }
// }

input[type="range"] {
  margin: auto;
  -webkit-appearance: none;
  position: relative;
  overflow: hidden;
  width: 100% !important;
  cursor: pointer;
  outline: none;
  background: transparent;
}

input[type="range"]:focus {
  outline: none;
}

::-webkit-slider-runnable-track {
  background: #c0f3e8;
}

/*
 * 1. Set to 0 width and remove border for a slider without a thumb
 */
::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 0;
  /* 1 */
  height: 8px;
  background: #c0f3e8;
  box-shadow: -100vw 0 0 100vw #06d0a6;
  border: none;
  /* 2px solid #999; */
}

::-moz-range-track {
  height: 8px;
  background: #ddd;
}

::-moz-range-thumb {
  background: #c0f3e8;
  height: 8px;
  width: 0;
  /* 20px; */
  border: none;
  /* 3px solid #999; */
  border-radius: 0 !important;
  box-shadow: -100vw 0 0 100vw #06d0a6;
  box-sizing: border-box;
}

::-ms-fill-lower {
  background: #06d0a6;
}

::-ms-thumb {
  background: #c0f3e8;
  height: 8px;
  width: 20px;
  box-sizing: border-box;
}

::-ms-ticks-after {
  display: none;
}

::-ms-ticks-before {
  display: none;
}

::-ms-track {
  background: #ddd;
  color: transparent;
  height: 8px;
  border: none;
}

::-ms-tooltip {
  display: none;
}
</style>
