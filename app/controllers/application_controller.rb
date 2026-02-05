class ApplicationController < ActionController::API
  # This hook ensures every request is checked for a valid user.
  before_action :authenticate_user!

  # If a user tries to access something they don't have permission for,
  # CanCanCan will raise this error. we catch it and return a clean JSON error.
  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: "Access Denied: #{exception.message}" }, status: :forbidden
  end

  # This method checks if the person calling the API is who they say they are.
  def authenticate_user!
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id]) if @decoded
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  attr_reader :current_user

  # Custom helper to restrict access to Admins.
  def authorize_admin!
    render json: { error: 'Forbidden' }, status: :forbidden unless current_user&.admin?
  end
end
