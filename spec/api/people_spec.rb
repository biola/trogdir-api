require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:method) { :get }
  let(:url) { "/v1/people" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }

  subject { response }

  describe 'GET /v1/people/:id' do
    # periods in the URL can be interpreted as extensions to test that they work specifically
    let!(:netid) { create :id, person: person, type: :netid, identifier: 'with.period' }
    let!(:biola_id) { create :id, person: person, type: :biola_id }

    let(:id) { netid }
    let(:url) { "/v1/people/#{id}" }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'without a type' do
      it 'finds a person by netid' do
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)['last_name']).to eql person.last_name
      end
    end

    context 'with a type' do
      let(:id) { biola_id }
      let(:params) { {type: 'biola_id'} }

      it 'finds a person by id type' do
        expect(response.status).to eql 200
        expect(JSON.parse(response.body)['_id']).to eql person._id.to_s
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

  describe 'POST /v1/people' do
    let(:method) { :post }
    let(:creation) { Person.first }

    context 'when unauthenticated' do
      before { post url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'without required params' do
      let(:params) { {first_name: 'Strong'} }
      its(:status) { should eql 400 }
    end

    context 'with required params' do
      let(:params) { {first_name: 'Strong', last_name: 'Bad'} }
      let(:creation) { Person.first }
      it 'creates a person' do
        expect(response.status).to eql 201
        expect(Person.count).to eql 1
        expect(creation.first_name).to eql 'Strong'
        expect(creation.last_name).to eql 'Bad'
      end
    end

    context 'with all params' do
      let(:params) { {
        first_name: 'Strong',
        preferred_name: 'Depressio',
        middle_name: 'P',
        last_name: 'Sad',
        display_name: 'Strong Sad',
        gender: 'male',
        partial_ssn: '0000',
        birth_date: 30.years.ago.to_s,
        entitlements: ['brothers:strong'],
        affiliations: ['cartoon'],
        privacy: 'true'
      } }
      it 'creates a person' do
        expect(response.status).to eql 201
        expect(Person.count).to eql 1
        expect(creation.first_name).to eql 'Strong'
        expect(creation.preferred_name).to eql 'Depressio'
        expect(creation.middle_name).to eql 'P'
        expect(creation.last_name).to eql 'Sad'
        expect(creation.display_name).to eql 'Strong Sad'
        expect(creation.gender).to eql :male
        expect(creation.partial_ssn).to eql '0000'
        expect(creation.birth_date).to eql 30.years.ago.to_date
        expect(creation.entitlements).to eql ['brothers:strong']
        expect(creation.affiliations).to eql ['cartoon']
        expect(creation.privacy).to eql true
      end
    end
  end
end