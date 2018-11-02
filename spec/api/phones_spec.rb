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
  end
end
