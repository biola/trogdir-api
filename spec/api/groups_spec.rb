require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let!(:syncinator) { create :syncinator }
  let(:method) { :put }
  let(:group) { 'nobodies' }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params, syncinator }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/groups/:group/people' do
    let(:method) { :get }
    let(:url) { "/v1/groups/#{group}/people" }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'with a non-existent group' do
      let(:group) { 'bogus' }
      its(:status) { should eql 200 }
      it{ expect(json).to eql [] }
    end

    context 'with people in a group' do
      let!(:person) { create :person, groups: ['nobodies'] }
      its(:status) { should eql 200 }
      it{ expect(json.length).to eql 1 }
      it{ expect(json.first['uuid']).to eql person.uuid }
    end
  end
end
