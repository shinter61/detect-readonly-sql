require 'rails_helper'

describe ApplicationController, type: :request do
  describe '#index' do
    subject { get "/" }
    
    it '正常時' do
      is_expected.to eq 200
    end
  end
end
