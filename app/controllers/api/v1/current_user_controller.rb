class Api::V1::CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    auth = request.headers["Authorization"]
    puts auth
    render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes], status: :ok
  end
end
