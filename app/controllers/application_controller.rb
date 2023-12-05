class ApplicationController < ActionController::Base
  def index
    users = User.all
    render json: users
  end
end
