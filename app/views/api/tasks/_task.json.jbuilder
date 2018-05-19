json.extract! task, :id, :created_at, :updated_at
json.url api_task_url(task, format: :json)
