require 'rails_helper'

describe UsersController, type: :request do
  describe '#index' do
    before do
      User.create(id: 1, name: 'matsumoto')
    end

    subject { get "/users" }
    
    it '正常時' do
      is_expected.to eq 200
    end
  end

  describe '#show' do
    before do
      User.create(id: 1, name: 'matsumoto')
    end

    subject { get "/users/#{id}" }
    
    let(:id) { 1 }
    it '正常時' do
      is_expected.to eq 200
    end
  end

  describe '#create' do
    subject { post "/users", params: }
    
    let(:params) { { name: 'hoge' } }
    it '正常時' do
      is_expected.to eq 204
    end
  end
end
