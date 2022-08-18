import { createApp } from "vue";
import { createPinia } from "pinia";
import { isRunningOnPWA } from "./services/helpers";

import App from "./App.vue";
import router from "./router";

import "./assets/styles/styles.scss";
import "notyf/notyf.min.css";

const app = createApp(App);
const pinia = createPinia();

app.use(pinia).use(router);

if (isRunningOnPWA()) window.resizeTo(985, 677);

if (window.matchMedia && window.matchMedia("(prefers-color-scheme: light)").matches) {
  document.body.classList.add("light-theme");
}

app.mount("#app");
