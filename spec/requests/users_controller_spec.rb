require 'rails_helper'

describe UsersController, type: :request do
  describe '#index' do
    subject { get "/users" }
    
    it '正常時' do
      is_expected.to eq 200
    end
  end

  describe '#show' do
    subject { get "/users/#{id}" }
    
    let(:id) { 1 }
    it '正常時' do
      is_expected.to eq 200
    end
  end
end
