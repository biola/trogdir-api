require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:url) { '/' }
  let(:response) { get url }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /root' do
    its(:status) { should eql 404 }
    it { expect(json).to have_key :error }
    it { expect(json[:error]).to match 'Not Found' }
  end

  describe 'GET /whatever' do
    its(:status) { should eql 404 }
    it { expect(json).to have_key :error }
    it { expect(json[:error]).to match 'Not Found' }
  end
end