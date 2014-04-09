require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.uuid }
  let(:method) { :get }
  let(:url) { "/v1/people/#{person_id}/emails" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/people/:person_id/emails' do
    let!(:university) { create :email, person: person, type: :university, primary: true }
    let!(:personal) { create :email, person: person, type: :personal, address: 'trogdor@example.com' }
    let(:email_id) { personal.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'id' => university.id.to_s, 'type' => university.type.to_s, 'address' => university.address, 'primary' => university.primary}, {'id' => personal.id.to_s, 'type' => personal.type.to_s, 'address' => personal.address, 'primary' => personal.primary}] }

    describe 'GET /v1/people/:person_id/emails/:email_id' do
      let(:url) { "/v1/people/#{person_id}/emails/#{personal.id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql id: personal.id.to_s, type: personal.type.to_s, address: personal.address, primary: false }
    end

    describe 'POST /v1/people/:person_id/emails' do
      let(:method) { :post }
      let(:params) { {type: 'personal', address: 'the.cheat@example.com'} }
      its(:status) { should eql 201 }
      it { expect { signed_post(url, params) }.to change { person.reload.emails.count }.by 1 }
    end

    describe 'PUT /v1/people/:person_id/emails/:email_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/emails/#{email_id}" }
      let(:params) { {address: 'burninator@example.com'} }
      its(:status) { should eql 200 }
      it { expect { signed_put(url, params) }.to change { personal.reload.address }.from('trogdor@example.com').to 'burninator@example.com' }
    end

    describe 'DELETE /v1/people/:person_id/emails/:email_id' do
      let(:method) { :delete }
      let(:url) { "/v1/people/#{person_id}/emails/#{email_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.emails.count }.by -1 }
    end
  end
end