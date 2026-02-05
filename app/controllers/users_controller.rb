# UsersController allows Admins to manage employees in the system.
class UsersController < ApplicationController
  # CanCanCan will automatically load the user(s) and check permissions.
  load_and_authorize_resource

  # GET /users - Lists all users in the system.
  def index
    render json: @users
  end

  # POST /users - Admins create a new employee (or admin).
  def create
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users/:id - Shows details of a specific user.
  def show
    render json: @user
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :employee_id)
  end
end
