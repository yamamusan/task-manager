json.extract! task, :id, :created_at, :updated_at, :title, :description
json.url task_url(task, format: :json)
