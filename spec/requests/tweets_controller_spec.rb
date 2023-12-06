require 'rails_helper'

describe TweetsController, type: :request do
  describe '#index' do
    before do
      user = User.create(id: 1, name: 'matsumoto')
      tweet = Tweet.create(id: 1, post: 'hello')
      user.tweets << tweet
    end

    subject { get "/tweets" }
    
    it '正常時' do
      is_expected.to eq 200
    end
  end

  describe '#create' do
    before do
      User.create(id: 1, name: 'matsumoto')
    end

    subject { post "/tweets", params: }

    let(:params) { { post: "I'm fine" } }
    
    it '正常時' do
      is_expected.to eq 204
    end
  end

  describe '#destroy' do
    before do
      user = User.create(id: 1, name: 'matsumoto')
      tweet = Tweet.new(id: 1, post: 'hello')
      tweet2 = Tweet.new(id: 2, post: 'goodbye')
      user.tweets << [tweet, tweet2]
    end

    subject { delete "/tweets/#{id}"}

    let(:id) { 1 }
    
    it '正常時' do
      is_expected.to eq 204
    end
  end
end
