json.extract! task, :id, :created_at, :updated_at, :title, :description, :priority, :status
json.url task_url(task, format: :json)
