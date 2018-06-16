<template>
  <div>

    <!-- TODO:ボタンは縦中央にしたい -->
    <div class="taskul-title-area">
      <p class="h2 d-inline">タスク</p>
      <button class="btn btn-secondary" data-toggle="modal" data-target="#task-register">新規登録</button>
    </div>

    <div class="taskul-title-area">
      <!-- TODO: 反転もできるようにしたい -->
      <button class="btn btn-primary btn-sm" @click="statusGet('todo')">未着手</button>
      <button class="btn btn-secondary btn-sm" @click="statusGet('doing')">着手</button>
      <button class="btn btn-success btn-sm" @click="statusGet('done')">完了</button>
      <button class="btn btn-secondary pull-right ">詳細検索</button>
    </div>

    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <!-- TODO:本当はヘッダをチェクしたら、全体のOn/Offを切り替えたい -->
            <th scope="col"><input type="checkbox" id="checkbox-header" class="styled"></th>
            <th scope="col">タイトル</th>
            <th scope="col">優先度</th>
            <th scope="col">ステータス</th>
            <th scope="col">終了期限</th>
            <th scope="col">更新日時</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(task, index) in tasklist" v-bind:key="task.id">
            <th scope="row"><input type="checkbox" v-bind:id="'checkbox' +  index" class="styled"></th>
            <td>{{ task.title }}</td>
            <td>{{ task.priority }}</td>
            <td>{{ task.status }}</td>
            <td>{{ task.due_date }}</td>
            <td>{{ task.updated_at }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="modal fade" id="task-register" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">新しいタスクを作成</h5>
          </div>
          <div class="modal-body">
            <form>
              <div class="form-group">
                <label for="title">タイトル</label>
                <input type="text" class="form-control" v-model="task.title" id="title">
              </div>
              <div class="form-group">
                <label for="description">説明</label>
                <textarea rows="3" class="form-control" v-model="task.description" id="description"></textarea>
              </div>
              <div class="form-group">
                <label for="priority">優先度</label>
                <select class="custom-select" v-model.number="task.priority" id="priority">
                  <option value="-1">低</option>
                  <option value="0" selected>中</option>
                  <option value="1">高</option>
                </select>
              </div>
              <div class="form-group">
                <label for="status">ステータス</label>
                <select class="custom-select" v-model.number="task.status" id="status">
                  <option value="0" selected>新規</option>
                  <option value="1">着手</option>
                  <option value="2">完了</option>
                </select>
              </div>
            </form>
            <button class="btn btn-primary pull-right" @click="registerTask">新規登録</button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'tasks',
  data() {
    return {
      tasklist: [],
      statuses: [],
      task: {
        title: '',
        description: '',
        status: 0,
        priority: 0
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
    registerTask: function() {
      axios.post('/api/tasks', this.task).then(
        response => {
          $('#task-register').modal('hide')
          this.fetchTasks()
        },
        error => {
          console.log(error)
        }
      )
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
    }
  }
}
</script>
