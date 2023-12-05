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
end
