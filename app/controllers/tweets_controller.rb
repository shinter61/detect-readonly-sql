class TweetsController < ApplicationController
  def index
    user = User.first
    tweets = user.tweets
    render json: tweets
  end

  def create
    user = User.first
    tweet = Tweet.new(post: params[:post])
    user.tweets << tweet
  end

  def destroy
    user = User.first

    ActiveRecord::Base.transaction do
      target_tweet = user.tweets.where(id: params[:id]).first
      target_tweet.destroy
    end
  end
end
