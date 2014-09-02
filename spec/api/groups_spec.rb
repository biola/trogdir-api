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

  describe 'PUT /v1/groups/:group/add' do
    let(:url) { "/v1/groups/#{group}/add" }

    context 'when unauthenticated' do
      before { put url, identifier: '42' }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'with an invalid identifier' do
      let(:params) { {identifier: 'nope'} }
      it { expect(response.status).to eql 404 }
    end

    context 'with a valid identifier and type' do
      let(:person) { create :person }
      let(:id) { create :id, person: person }
      let(:params) { {identifier: id.identifier, type: id.type.to_s} }
      it { expect(response.status).to eql 200 }
    end

    context 'when person is already in the group' do
      let!(:person) { create :person, groups: ['nobodies'] }
      let(:params) { {identifier: person.uuid} }

      it { expect(json[:result]).to be false }
    end

    context 'when person is not already in the group' do
      let!(:person) { create :person, groups: [] }
      let(:params) { {identifier: person.uuid} }

      it { expect(json[:result]).to be true }
    end
  end

  describe 'PUT /v1/groups/:group/remove' do
    let(:url) { "/v1/groups/#{group}/remove" }

    context 'when unauthenticated' do
      before { put url, identifier: '42' }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'with an invalid identifier' do
      let(:params) { {identifier: 'nope'} }
      it { expect(response.status).to eql 404 }
    end

    context 'with a valid identifier and type' do
      let(:person) { create :person, groups: ['nobodies'] }
      let(:id) { create :id, person: person }
      let(:params) { {identifier: id.identifier, type: id.type.to_s} }
      it { expect(response.status).to eql 200 }
    end

    context 'when person is in the group' do
      let!(:person) { create :person, groups: ['nobodies'] }
      let(:params) { {identifier: person.uuid} }

      it { expect(json[:result]).to be true }
    end

    context 'when person is not in the group' do
      let!(:person) { create :person, groups: [] }
      let(:params) { {identifier: person.uuid} }

      it { expect(json[:result]).to be false }
    end
  end
end
