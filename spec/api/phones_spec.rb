require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.uuid }
  let(:method) { :get }
  let(:url) { "/v1/people/#{person_id}/phones" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/people/:person_id/phones' do
    let!(:home) { create :phone, person: person, type: :home }
    let!(:cell) { create :phone, person: person, type: :cell, number: '123-123-1234' }
    let(:phone_id) { cell.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'id' => home.id.to_s, 'type' => home.type.to_s, 'number' => home.number, 'primary' => home.primary}, {'id' => cell.id.to_s, 'type' => cell.type.to_s, 'number' => cell.number, 'primary' => cell.primary}] }

    describe 'GET /v1/people/:person_id/phones/:phone_id' do
      let(:url) { "/v1/people/#{person_id}/phones/#{cell.id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql id: cell.id.to_s, type: cell.type.to_s, number: cell.number, primary: cell.primary }
    end

    describe 'POST /v1/people/:person_id/phones' do
      let(:method) { :post }
      let(:params) { {type: 'office', number: '123-123-1234', primary: true} }
      its(:status) { should eql 201 }
      it { expect { signed_post(url, params) }.to change { person.reload.phones.count }.by 1 }

      it 'creates a changeset' do
        expect { signed_post(url, params) }.to change { Changeset.count }.by 1
        expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
      end
    end

    describe 'PUT /v1/people/:person_id/phones/:phone_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/phones/#{phone_id}" }
      let(:params) { {number: '456-456-4567'} }
      its(:status) { should eql 200 }
      it { expect { signed_put(url, params) }.to change { cell.reload.number }.from('123-123-1234').to '456-456-4567' }

      it 'creates a changeset' do
        expect { signed_put(url, params) }.to change { Changeset.count }.by 1
        expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
      end
    end

    describe 'DELETE /v1/people/:person_id/phones/:phone_id' do
      let(:method) { :delete }
      let(:url) { "/v1/people/#{person_id}/phones/#{phone_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.phones.count }.by -1 }

      it 'creates a changeset' do
        expect { signed_delete(url, params) }.to change { Changeset.count }.by 1
        expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
      end
    end
  end
end
