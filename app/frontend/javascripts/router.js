import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'
import TaskList from './components/task-list.vue'
 
Vue.use(VueRouter)
 
export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: TaskList },
  ],
})