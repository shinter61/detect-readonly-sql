class TweetsController < ApplicationController
  def index
    tweets = User.first.tweets
    render json: tweets
  end
end
