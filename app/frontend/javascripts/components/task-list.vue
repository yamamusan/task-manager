<template>
  <div>

    <!-- TODO:ボタンは縦中央にしたい -->
    <div class="taskul-title-area">
      <p class="h2 d-inline">タスク</p>
      <button class="btn btn-primary" data-toggle="modal" data-target="#task-register">新規登録</button>
    </div>

    <!-- 登録・更新モーダル -->
    <task-form type="register" @reload="fetchTasks"></task-form>
    <task-form type="update" @reload="fetchTasks" ref="updateModal"></task-form>

    <div class="taskul-title-area">
      <!-- TODO: 反転もできるようにしたい -->
      <button class="btn btn-info btn-sm" @click="statusGet('todo')">未着手</button>
      <button class="btn btn-warning btn-sm" @click="statusGet('doing')">着手</button>
      <button class="btn btn-success btn-sm" @click="statusGet('done')">完了</button>
      <button class="btn btn-secondary pull-right mr-2 mb-2">詳細検索</button>
      <button class="btn btn-danger pull-right mr-2 mb-2" @click="deleteTasks">削除</button>
    </div>

    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <!-- TODO:本当はヘッダをチェクしたら、全体のOn/Offを切り替えたい -->
            <th scope="col"><input type="checkbox" id="checkbox-header" class="styled" @click="checkAll"></th>
            <th scope="col">＃</th>
            <th scope="col">タイトル</th>
            <th scope="col">優先度</th>
            <th scope="col">ステータス</th>
            <th scope="col">終了期限</th>
            <th scope="col">更新日時</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(task) in tasklist" v-bind:key="task.id">
            <th scope="row"><input type="checkbox" :id="'checkbox' + task.id" :data-id="task.id" class="styled checkbox-list"></th>
            <td>{{ task.id }}</td>
            <td>
              <a href="#" @click.prevent="openTaskModal(task.id)">{{ task.title }}</a>
            </td>
            <td>{{ task.priority }}</td>
            <td>{{ task.status }}</td>
            <td>{{ task.due_date }}</td>
            <td>{{ task.updated_at }}</td>
          </tr>
        </tbody>
      </table>
    </div>

  </div>
</template>

<script>
import axios from 'axios'
import TaskForm from './task-form.vue'

export default {
  name: 'tasks',
  components: {
    TaskForm
  },
  data() {
    return {
      tasklist: [],
      statuses: [],
      id: 0,
      task: {
        id: '',
        title: '',
        description: '',
        status: 0,
        priority: 0,
        due_date: ''
      }
    }
  },
  mounted: function() {
    this.fetchTasks()
  },
  methods: {
    statusGet: function(status) {
      this.statuses.includes(status) || this.statuses.push(status)
      let params = { statuses: this.statuses }
      this.fetchTasks(params)
    },
    fetchTasks: function(params) {
      this.tasklist = []
      axios.get('/api/tasks', { params: params }).then(
        response => {
          for (let i = 0; i < response.data.length; i++) {
            this.tasklist.push(response.data[i])
          }
        },
        error => {
          console.log(error)
        }
      )
    },
    // TODO: Jqueryごりごり感が強いので、dataにチェック値を入れといて取得する感じにしたい
    deleteTasks: function(params) {
      let ids = []
      $('.checkbox-list:checked').each(function() {
        ids.push($(this).data('id'))
      })
      axios.delete('/api/tasks', { data: { ids: ids } }).then(
        response => {
          alert('削除しました')
          this.fetchTasks(params)
        },
        error => {
          console.log(error)
        }
      )
    },
    openTaskModal: function(id) {
      this.$refs.updateModal.openModal(id)
      $('#task-update').modal('show')
    },
    checkAll: function() {
      $('.checkbox-list').prop('checked', $('#checkbox-header').prop('checked'))
    }
  }
}
</script>
