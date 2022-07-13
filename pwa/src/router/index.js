import { createRouter, createWebHistory } from 'vue-router';
// Async Components
const HomeView = () => import('../views/HomeView.vue');
const StreamView = () => import('../views/StreamView.vue');
const UploadView = () => import('../views/UploadView.vue');
const MintView = () => import('../views/MintView.vue');

const router = createRouter({
  scrollBehavior(to, from, savedPosition) {
    if (to.hash) {
      return window.scrollTo({
        top: document.querySelector(to.hash).offsetTop - 135,
        behavior: 'smooth',
      });
    } else {
      return savedPosition || { top: 0, left: 0 };
    }
  },
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/upload',
      name: 'upload',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: UploadView,
    },
    {
      path: '/stream',
      name: 'stream',
      component: StreamView,
    },
    {
      path: '/mint',
      name: 'mint',
      component: MintView,
    },
  ],
});

export default router;
