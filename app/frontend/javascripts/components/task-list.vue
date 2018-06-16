<template>
  <div>

    <!-- TODO:ボタンは縦中央にしたい -->
    <div class="taskul-title-area">
      <p class="h2 d-inline">タスク</p>
      <button type="button" class="btn btn-secondary">新規登録</button>
    </div>

    <div class="taskul-title-area">
      <button type="button" class="btn btn-primary btn-sm">未着手</button>
      <button type="button" class="btn btn-secondary btn-sm">着手</button>
      <button type="button" class="btn btn-success btn-sm">完了</button>
      <button type="button" class="btn btn-secondary float-right ">詳細検索</button>
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

  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'tasks',
  data() {
    return {
      tasklist: []
    }
  },
  mounted: function() {
    this.fetchTasks()
  },
  methods: {
    fetchTasks: function() {
      axios.get('/api/tasks').then(
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
