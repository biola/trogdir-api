require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.id }
  let(:method) { :get }
  let(:url) { "/v1/people/#{person_id}/ids" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/people/:person_id/ids' do
    let!(:netid) { create :id, person: person, type: :netid }
    let!(:biola_id) { create :id, person: person, type: :biola_id, identifier: '0000000' }
    let(:id_id) { biola_id.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'type' => netid.type.to_s, 'identifier' => netid.identifier}, {'type' => biola_id.type.to_s, 'identifier' => biola_id.identifier}] }

    describe 'GET /v1/people/:person_id/ids/:id_id' do
      let(:url) { "/v1/people/#{person_id}/ids/#{id_id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql type: biola_id.type.to_s, identifier: biola_id.identifier }
    end

    describe 'POST /v1/people/:person_id/ids' do
      let(:method) { :post }
      let(:params) { {type: 'google_apps', identifier: 'the.cheat'} }
      its(:status) { should eql 201 }
      it { expect { signed_post(url, params) }.to change { person.reload.ids.count }.by 1 }
    end

    describe 'PUT /v1/people/:person_id/ids/:id_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/ids/#{id_id}" }
      let(:params) { {identifier: '1234567'} }
      its(:status) { should eql 200 }
      it { expect { signed_put(url, params) }.to change { biola_id.reload.identifier }.from('0000000').to '1234567' }
    end

    describe 'DELETE /v1/people/:person_id/ids/:id_id' do
      let(:method) { :delete }
      let(:url) { "/v1/people/#{person_id}/ids/#{id_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.ids.count }.by -1 }
    end
  end
end