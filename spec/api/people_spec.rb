require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }

  describe 'GET /v1/people/:id' do
    # periods in the URL can be interpreted as extensions to test that they work specifically
    let!(:netid) { create :id, person: person, type: :netid, identifier: 'with.period' }
    let!(:biola_id) { create :id, person: person, type: :biola_id }

    context 'unauthenticated request' do
      it '401s' do
        get "/v1/people/#{netid}"
        expect(last_response.status).to eql 401
      end
    end

    context 'without a type' do
      it 'finds a person by netid' do
        signed_get "/v1/people/#{netid}" do |response|
          expect(response.status).to eql 200
          expect(JSON.parse(response.body)['last_name']).to eql person.last_name
        end
      end
    end

    context 'with a type' do
      it 'finds a person by id type' do
        signed_get "/v1/people/#{biola_id}", type: 'biola_id' do |response|
          expect(response.status).to eql 200
          expect(JSON.parse(response.body)['_id']).to eql person._id.to_s
        end
      end
    end

    context 'with an bogus id' do
      it '404s' do
        signed_get "/v1/people/#{netid}", type: 'biola_id' do |response|
          expect(response.status).to eql 404
        end
      end
    end

    context 'with an bogus type' do
      it '400s' do
        signed_get "/v1/people/#{netid}", type: 'bogus' do |response|
          expect(response.status).to eql 400
        end
      end
    end

    context 'with full data' do
      let!(:email) { create :email, person: person }
      let!(:photo) { create :photo, person: person }
      let!(:phone) { create :phone, person: person }
      let!(:address) { create :address, person: person }
      let(:response) { signed_get "/v1/people/#{netid}" }
      subject { JSON.parse(response.body).deep_symbolize_keys }

      it 'has expected values' do
        expect(subject[:ids].first.symbolize_keys).to eql type: netid.type.to_s, identifier: netid.identifier
        expect(subject[:emails].first.symbolize_keys).to eql type: email.type.to_s, address: email.address, primary: false
        expect(subject[:photos].first.symbolize_keys).to eql type: photo.type.to_s, url: photo.url, height: photo.height, width: photo.width
        expect(subject[:phones].first.symbolize_keys).to eql type: phone.type.to_s, number: phone.number
        expect(subject[:addresses].first.symbolize_keys).to eql type: address.type.to_s, street_1: address.street_1, street_2: address.street_2, city: address.city, state: address.state, zip: address.zip, country: address.country

        # Names
        expect(subject[:first_name]).to eql person.first_name
        expect(subject[:preferred_name]).to eql person.preferred_name
        expect(subject[:middle_name]).to eql person.middle_name
        expect(subject[:last_name]).to eql person.last_name
        expect(subject[:display_name]).to eql person.display_name

        # Demographic
        expect(subject[:gender]).to eql person.gender.to_s
        expect(subject[:partial_ssn]).to eql person.partial_ssn
        expect(subject[:birth_date]).to eql person.birth_date.to_s

        # Groups and permissions
        expect(subject[:entitlements]).to eql person.entitlements
        expect(subject[:affiliations]).to eql person.affiliations

        # Options
        expect(subject[:privacy]).to eql person.privacy
        expect(subject[:enabled]).to eql person.enabled
      end
    end
  end
end