import { createRouter, createWebHistory } from "vue-router";
const baseURL = "";
// Async Components
const HomeView = () => import("../views/HomeView.vue");
const CollectionView = () => import("../views/CollectionView.vue");
const StreamView = () => import("../views/StreamView.vue");
const ExploreView = () => import("../views/ExploreView.vue");
const MintView = () => import("../views/MintView.vue");
const UploadView = () => import("../views/UploadView.vue");
const ProfileView = () => import("../views/ProfileView.vue");

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
      path: "/profile",
      name: "profile",
      component: ProfileView,
    },
    {
      path: "/upload",
      name: "upload",
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: UploadView,
    },
  ],
});

export default router;
