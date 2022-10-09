import { createRouter, createWebHistory } from "vue-router";
const baseURL = "";

/* Async Components */
const HomeView = () => import("../views/HomeView.vue");
const CollectionView = () => import("../views/CollectionView.vue");
const StreamView = () => import("../views/StreamView.vue");
const ExploreView = () => import("../views/ExploreView.vue");
const MintView = () => import("../views/MintView.vue");
const UploadView = () => import("../views/UploadView.vue");
const AccountView = () => import("../views/AccountView.vue");

const router = createRouter({
  scrollBehavior(to, from, savedPosition) {
    if (to.hash) {
      return window.scrollTo({
        top: document.querySelector(to.hash).offsetTop - 135,
        behavior: "smooth",
      });
    } else {
      return savedPosition || { top: 0, left: 0 };
    }
  },
  history: createWebHistory(baseURL),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView,
    },
    {
      path: "/collection",
      name: "collection",
      component: CollectionView,
    },
    {
      path: "/stream",
      name: "stream",
      component: StreamView,
    },
    {
      path: "/explore",
      name: "explore",
      component: ExploreView,
    },
    {
      path: "/mint",
      name: "mint",
      component: MintView,
    },
    {
      path: "/account",
      name: "account",
      component: AccountView,
    },
    {
      path: "/upload",
      name: "upload",
      component: UploadView,
    },
  ],
});

export default router;
