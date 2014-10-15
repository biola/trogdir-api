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
      context 'without limit set' do
        let!(:person) { create :person }

        it 'returns sync_logs' do
          expect(response.status).to eql 200
          expect(json.first).to have_key 'sync_log_id'
          expect(json.first['sync_log_id']).to be_a String
          expect(json.first['action']).to eql 'create'
          expect(json.first['person_id']).to eql person.uuid.to_s
          expect(json.first['affiliations']).to eql person.affiliations
          expect(json.first['scope']).to eql 'person'
          expect(json.first['original']).to eql({})
          expect(json.first['modified']).to be_a Hash
          expect(json.first).to have_key 'created_at'
        end

        it 'starts the change_syncs' do
          expect { signed_put(url, params, syncinator) }.to change { syncinator.reload.startable_changesets.length }.from(1).to 0
        end
      end

      context 'with limit set to 1' do
        let(:params) { {limit: '1'} }
        before { create_list :person, 2 }

        it 'returns just one sync_log' do
          expect(json.length).to eql 1
        end
      end
    end
  end

  describe 'PUT /v1/change_syncs/error' do
    let(:change_sync) { create :change_sync, syncinator: syncinator }
    let(:sync_log) { create :sync_log, change_sync: change_sync }
    let(:url) { "/v1/change_syncs/error/#{sync_log.id}" }
    let(:params) { {message: 'Slightly shotgunned'} }

    context 'when authenticated as another syncinator' do
      let(:change_sync) { create :change_sync, syncinator: create(:syncinator) }
      its(:status) { should eql 401 }
    end

    it 'sets errored_at and message' do
      expect(response.status).to eql 200
      expect(json[:errored_at]).to_not be_empty
      expect(json[:message]).to eql 'Slightly shotgunned'
    end
  end

  describe 'PUT /v1/change_syncs/finish' do
    let(:change_sync) { create :change_sync, syncinator: syncinator }
    let(:sync_log) { create :sync_log, change_sync: change_sync }
    let(:url) { "/v1/change_syncs/finish/#{sync_log.id}" }
    let(:params) { {action: 'created', message: 'Did stuff'} }

    context 'when authenticated as another syncinator' do
      let(:change_sync) { create :change_sync, syncinator: create(:syncinator) }
      its(:status) { should eql 401 }
    end

    it 'sets succeeded_at, action and message' do
      expect(response.status).to eql 200
      expect(json[:succeeded_at]).to_not be_empty
      expect(json[:action]).to eql 'created'
      expect(json[:message]).to eql 'Did stuff'
    end
  end
end
