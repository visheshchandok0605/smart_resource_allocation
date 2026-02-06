class SessionsController < ApplicationController
  # We skip authentication for login otherwise you can never log in!
  skip_before_action :authenticate_user!, only: [:login]

  # POST /auth/login
  def login
    user = User.find_by(email: params[:email])

    # authenticate is a method provided by 'has_secure_password' in the User model.
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: UserBlueprint.render_as_hash(user) }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
