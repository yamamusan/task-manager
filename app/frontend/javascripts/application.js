import 'bootstrap/dist/js/bootstrap'
import Vue from 'vue/dist/vue.esm.js'
import Header from './components/header.vue'

var app = new Vue({
  el: '#app',
  components: {
    'navbar': Header,
  }
});
