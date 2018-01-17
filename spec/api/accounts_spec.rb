require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.uuid }
  let(:method) { :get }
  let(:url) { "/v1/people/#{person_id}/accounts" }
  let(:params) { {} }
  let(:response) { send("signed_#{method}".to_sym, url, params) }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys  if js.respond_to? :deep_symbolize_keys
    js
  end
  let!(:university_account) { UniversityAccount.create person: person, _type: 'UniversityAccount' }
  let(:account_id) { university_account.id }

  subject { response }

  context 'when unauthenticated' do
    before { get url }
    subject { last_response }
    its(:status) { should eql 401 }
  end

  describe 'GET /v1/people/:person_id/accounts' do
    its(:status) { should eql 200 }
    it { expect(json).to eql [{ 'id' => university_account.id.to_s, '_type' => university_account._type, 'person_id' => person.id.to_s, 'modified_by' => nil, 'confirmation_key' => university_account.confirmation_key, 'confirmed_at' => nil } ] }
  end

  describe 'GET /v1/people/:person_id/accounts/:account_id' do
    let(:url) { "/v1/people/#{person_id}/accounts/#{account_id}"}
    its(:status) { should eql 200 }
    it { expect(json).to eql id: university_account.id.to_s, _type: university_account._type, modified_by: nil, confirmation_key: university_account.confirmation_key, person_id: person.id.to_s, confirmed_at: nil }
  end

  describe 'POST /v1/people/:person_id/accounts' do
    let(:method) { :post }
    let(:params) { { _type: 'UniversityAccount' } }
    its(:status) { should eql 201 }
    it { expect { signed_post(url, params) }.to change { person.reload.accounts.count }.by 1 }

    it 'creates a changeset' do
      # TODO: figure out if we want this to create changesets.
      # expect { signed_post(url, params) }.to change { Changeset.count }.by 2
      # expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
    end
  end

  describe 'PUT /v1/people/:person_id/accounts/:account_id' do
    let(:method) { :put }
    let(:url) { "/v1/people/#{person_id}/accounts/#{account_id}" }
    let(:params) { {modified_by: 'Strongbadia'} }
    its(:status) { should eql 200 }
    it { expect { signed_put(url, params) }.to change { university_account.reload.modified_by }.from(nil).to 'Strongbadia' }

    it 'creates a changeset' do
      # expect { signed_put(url, params) }.to change { Changeset.count }.by 1
      # expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
    end
  end

  describe 'DELETE /v1/people/:person_id/accounts/:account_id' do
    let(:method) { :delete }
    let(:url) { "/v1/people/#{person_id}/accounts/#{account_id}" }
    its(:status) { should eql 200 }
    it { expect { signed_delete(url, params) }.to change { person.reload.accounts.count }.by -1 }

    it 'creates a changeset' do
      # expect { signed_delete(url, params) }.to change { Changeset.count }.by 1
      # expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
    end
  end
end
