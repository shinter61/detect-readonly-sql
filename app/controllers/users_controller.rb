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

  def update
    user = ActiveRecord::Base.transaction do
      User.find(params[:id])
    end

    ActiveRecord::Base.transaction do
      user.update(name: params[:name])
    end

    tweets = user.tweets

    ActiveRecord::Base.transaction do
      tweets.each do |tweet|
        tweet.update(updated_at: Time.zone.now)
      end
    end

    tweets = ActiveRecord::Base.transaction do
      user.tweets
    end
  end
end
