# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  # before_action :configure_permitted_parameters
  include RackSessionsFix
  include ActionController::Cookies 
  before_action :skip_verify_signed_out_user, only: :destroy
  respond_to :json

    # GET /resource/sign_in
  def new
    super
  end

  def destroy
    jwt_token = cookies[:jwt_token]

    puts cookies[:jwt_token]

    if jwt_token.present?
      if token_not_expired?(jwt_token)
        # Token is valid, proceed with logout logic
        sign_out(resource_name)
        cookies.delete(:jwt_token) # Clear the cookie on successful logout
        respond_to_on_destroy
      else
        # Token has expired, treat it as a valid logout
        # You might want to clear the cookie for expired tokens as well
        cookies.delete(:jwt_token)
        sign_out(resource_name)
        respond_to_on_destroy_expired
      end
    else
      # Token is not present, handle as needed
      # ...

      respond_to_on_destroy_missing_token
    end
  end
  # POST /resource/sign_in
  def create
    super do |resource|
      if resource.persisted?
        # Access the generated JWT token
        jwt_token = request.env['warden-jwt_auth.token']

        # Do something with the JWT token if needed
        # For example, you can store it in a cookie
        cookies[:jwt_token] = { value: jwt_token, httponly: true }
      end
    end
  end
  
  private

  def skip_verify_signed_out_user
    request.env["devise.skip_trackable"] = true
  end

  def respond_with(current_user, _opts = {})
    render json: {
      status: { 
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes]}
      }
    }, status: :ok
  end
  def token_not_expired?(token)
    decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, algorithm: 'HS256').first
    # Add any additional checks for token validity here
    !decoded_token['exp'].present? || decoded_token['exp'] > Time.now.to_i
  rescue JWT::ExpiredSignature
    false
  rescue JWT::DecodeError, JWT::VerificationError
    false
  end

  def respond_to_on_destroy
    render json: {
      status: 200,
      message: 'Logged out successfully.'
    }, status: :ok
  end

  def respond_to_on_destroy_expired
    render json: {
      status: 200,
      message: 'Token has expired. Logged out successfully.'
    }, status: :ok
  end

  def respond_to_on_destroy_missing_token
    render json: {
      status: 401,
      message: "Couldn't find an active session."
    }, status: :unauthorized
  end
end



  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
