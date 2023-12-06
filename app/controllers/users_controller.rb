class UsersController < ApplicationController
  def index
    users = User.all
    render json: users
  end

  def show
    user = ActiveRecord::Base.transaction do
      User.find(params[:id])
    end

    tweets = ActiveRecord::Base.transaction do
      user.tweets.limit(10)
    end

    render json: { user: user, tweets: tweets }
  end

  def create
    User.create(name: params[:name])
  end
end
