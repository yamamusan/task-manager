# frozen_string_literal: true

class Api::TasksController < ApplicationController
  before_action :set_task, only: %i[show update destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    condition = Task.new(search_params)
    @tasks = condition.search
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show; end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    if @task.save
      render :show, status: :created, location: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    if @task.update(task_params)
      render :show, status: :ok, location: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def delete
    # TODO: SELECTしてから１件ずつDELETEしているので性能悪そう
    Task.where(id: params[:ids]).destroy_all
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def task_params
    # 許可する項目だけを記載する
    params.fetch(:task, {}).permit(:title, :description, :status, :priority, :due_date)
  end

  def search_params
    # 許可する項目だけを記載する
    params.permit(:title, :due_date, :description, statuses: [], priorities: [])
  end
end
