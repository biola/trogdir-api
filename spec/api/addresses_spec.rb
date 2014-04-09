require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.uuid }
  let(:method) { :get }
  let(:url) { "/v1/people/#{person_id}/addresses" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/people/:person_id/addresses' do
    let!(:home) { create :address, person: person, type: :home, street_1: 'The Stick' }
    let(:address_id) { home.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'id' => home.id.to_s, 'type' => home.type.to_s, 'street_1' => home.street_1, 'street_2' => home.street_2, 'city' => home.city, 'state' => home.state, 'zip' => home.zip, 'country' => home.country}] }

    describe 'GET /v1/people/:person_id/addresses/:address_id' do
      let(:url) { "/v1/people/#{person_id}/addresses/#{home.id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql id: home.id.to_s, type: home.type.to_s, street_1: home.street_1, street_2: home.street_2, city: home.city, state: home.state, zip: home.zip, country: home.country }
    end

    describe 'POST /v1/people/:person_id/addresses' do
      let(:method) { :post }
       let(:params) { {type: 'home', street_1: '123 Nowhere St'} }
      its(:status) { should eql 201 }
      it { expect { signed_post(url, params) }.to change { person.reload.addresses.count }.by 1 }
    end

    describe 'PUT /v1/people/:person_id/addresses/:address_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/addresses/#{address_id}" }
      let(:params) { {street_1: 'Strongbadia'} }
      its(:status) { should eql 200 }
      it { expect { signed_put(url, params) }.to change { home.reload.street_1 }.from('The Stick').to 'Strongbadia' }
    end

    describe 'DELETE /v1/people/:person_id/addresses/:address_id' do
      let(:method) { :delete }
      let(:url) { "/v1/people/#{person_id}/addresses/#{address_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.addresses.count }.by -1 }
    end
  end
end