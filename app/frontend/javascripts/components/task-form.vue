<template>
  <div>

    <!-- タスク登録・更新モーダル -->
    <div class="modal fade" :id="'task-' + type" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <div v-if="type === 'register'">
              <h5 class="modal-title">新しいタスクを作成</h5>
            </div>
            <div v-else>
              <h5 class="modal-title">タスクを更新</h5>
            </div>
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
                <div class="form-group">
                  <label for="due-date">期限</label>
                  <input type="date" class="form-control" id="due-date" v-model="task.due_date">
                </div>
              </div>
            </form>

            <div v-if="type === 'register'">
              <button class="btn btn-primary pull-right" @click="registerTask">新規登録</button>
            </div>
            <div v-else>
              <button class="btn btn-primary pull-right" @click="updateTask">更新</button>
            </div>

          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'taskform',
  props: {
    type: { type: String, required: true }
  },
  data() {
    return {
      task: {
        id: 0,
        title: '',
        description: '',
        status: 0,
        priority: 0,
        due_date: ''
      }
    }
  },
  mounted: function() {
    if (this.type === 'update') {
      // モーダルイベントにフックする場合はこちら
      // $('#task-update').on('shown.bs.modal', this.openModal)
      $('#task-update').on('hide.bs.modal', this.closeModal)
    }
  },
  methods: {
    // TODO: ポップアップはalertじゃなくてちゃんとする
    registerTask: function() {
      axios.post('/api/tasks', this.task).then(
        response => {
          alert('登録しました')
          $('#task-register').modal('hide')
          this.$emit('reload')
          Object.assign(this.$data, this.$options.data())
        },
        error => {
          console.log(error)
        }
      )
    },
    updateTask: function() {
      axios.patch(`/api/tasks/${this.task.id}`, this.task).then(
        response => {
          alert('更新しました')
          $('#task-update').modal('hide')
          this.$emit('reload')
          Object.assign(this.$data, this.$options.data())
        },
        error => {
          console.log(error)
        }
      )
    },
    // TODO: ステータスとかの値をセットする
    openModal: function(id) {
      this.task.id = id
      axios.get(`/api/tasks/${id}`).then(
        response => {
          this.task = response.data
          $('#task-update').modal('show')
        },
        error => {
          console.log(error)
        }
      )
    },
    closeModal: function() {
      Object.assign(this.$data, this.$options.data())
    }
  }
}
</script>
