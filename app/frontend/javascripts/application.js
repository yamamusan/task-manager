import 'bootstrap/dist/js/bootstrap'
import Vue from 'vue/dist/vue.esm.js'
import Router from './router.js'
import Header from './components/header.vue'

var app = new Vue({
  el: '#app',
  router: Router,
  components: {
    'navbar': Header,
  },
});
