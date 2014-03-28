require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let!(:syncinator) { create :syncinator }
  let(:method) { :put }
  let(:url) { '/v1/change_syncs' }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params, syncinator }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'PUT /v1/change_syncs/start' do
    let(:url) { '/v1/change_syncs/start' }

    context 'when unauthenticated' do
      before { put url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'without unstarted change_syncs' do
      it 'returns an empty array' do
        expect(response.status).to eql 200
        expect(json).to eql []
      end
    end

    context 'with unstarted change_syncs' do
      let!(:person) { create :person }

      it 'returns sync_logs' do
        expect(response.status).to eql 200
        expect(json.first).to have_key 'sync_log_id'
        expect(json.first['action']).to eql 'create'
        expect(json.first['person_id']).to eql person.id.to_s
        expect(json.first['scope']).to eql 'person'
        expect(json.first['original']).to eql({})
        expect(json.first['modified']).to be_a Hash
        expect(json.first).to have_key 'created_at'
      end

      it 'starts the change_syncs' do
        expect { signed_put(url, params, syncinator) }.to change { syncinator.reload.startable_changesets.length }.from(1).to 0
      end
    end
  end

  describe 'PUT /v1/change_syncs/error' do
    let!(:person) { create :person }
    let(:sync_log) { create(:sync_log) }
    let(:url) { "/v1/change_syncs/error/#{sync_log.id}" }
    let(:params) { {message: 'Slightly shotgunned'} }

    it 'sets errored_at and message' do
      expect(response.status).to eql 200
      expect(json[:errored_at]).to_not be_empty
      expect(json[:message]).to eql 'Slightly shotgunned'
    end
  end

  describe 'PUT /v1/change_syncs/finish' do
    let(:sync_log) { create(:sync_log) }
    let(:url) { "/v1/change_syncs/finish/#{sync_log.id}" }
    let(:params) { {action: 'created', message: 'Did stuff'} }

    it 'sets succeeded_at, action and message' do
      expect(response.status).to eql 200
      expect(json[:succeeded_at]).to_not be_empty
      expect(json[:action]).to eql 'created'
      expect(json[:message]).to eql 'Did stuff'
    end
  end
end