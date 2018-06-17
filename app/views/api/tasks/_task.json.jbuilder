json.extract! task, :id, :created_at, :updated_at, :title, :description, :priority, :status, :due_date
json.url task_url(task, format: :json)
