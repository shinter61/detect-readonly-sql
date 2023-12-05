require 'rails_helper'

describe TweetsController, type: :request do
  describe '#index' do
    subject { get "/tweets" }
    
    it '正常時' do
      is_expected.to eq 200
    end
  end
end
