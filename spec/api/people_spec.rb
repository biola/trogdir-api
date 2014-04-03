require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.uuid }
  let(:method) { :get }
  let(:url) { "/v1/people" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/people' do
    let!(:person_a) { create :person, first_name: 'John', affiliations: [:student] }
    let!(:person_b) { create :person, first_name: 'Jane', affiliations: [:employee] }

    context 'without params' do
      it 'returns all people' do
        expect(json.length).to eql 2
      end
    end

    context 'with affiliation param' do
      let(:params) { {affiliation: 'employee'} }

      it 'returns only poeple matching affiliations' do
        expect(json.length).to eql 1
        expect(json.first['first_name']).to eql 'Jane'
      end
    end
  end

  describe 'GET /v1/people/:id' do
    let(:url) { "/v1/people/#{person_id}" }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'with an bogus id' do
      let(:person_id) { 'fhqwhgads' }

      its(:status) { should eql 404 }
    end

    context 'with full data' do
      let(:person) { create :person, :student, :employee }
      let!(:id) { create :id, person: person }
      let!(:email) { create :email, person: person }
      let!(:photo) { create :photo, person: person }
      let!(:phone) { create :phone, person: person }
      let!(:address) { create :address, person: person }

      it 'has expected values' do
        expect(json[:ids].first.symbolize_keys).to eql type: id.type.to_s, identifier: id.identifier
        expect(json[:emails].first.symbolize_keys).to eql type: email.type.to_s, address: email.address, primary: false
        expect(json[:photos].first.symbolize_keys).to eql type: photo.type.to_s, url: photo.url, height: photo.height, width: photo.width
        expect(json[:phones].first.symbolize_keys).to eql type: phone.type.to_s, number: phone.number, primary: false
        expect(json[:addresses].first.symbolize_keys).to eql type: address.type.to_s, street_1: address.street_1, street_2: address.street_2, city: address.city, state: address.state, zip: address.zip, country: address.country

	# ID
        expect(json[:uuid]).to eql person.uuid

        # Names
        expect(json[:first_name]).to eql person.first_name
        expect(json[:preferred_name]).to eql person.preferred_name
        expect(json[:middle_name]).to eql person.middle_name
        expect(json[:last_name]).to eql person.last_name
        expect(json[:display_name]).to eql person.display_name

        # Demographic
        expect(json[:gender]).to eql person.gender.to_s
        expect(json[:partial_ssn]).to eql person.partial_ssn
        expect(json[:birth_date]).to eql person.birth_date.to_s

        # Groups and permissions
        expect(json[:entitlements]).to eql person.entitlements
        expect(json[:affiliations]).to eql person.affiliations

        # Options
        expect(json[:enabled]).to eql person.enabled

        # STUDENT INFO #

        # On-Campus Residence
        expect(json[:residence]).to eql person.residence
        expect(json[:floor]).to eql person.floor
        expect(json[:wing]).to eql person.wing

        # Academic
        expect(json[:majors]).to eql person.majors

        # FERPA
        expect(json[:privacy]).to eql person.privacy

        # EMPLOYEE INFO #
        expect(json[:department]).to eql person.department
        expect(json[:title]).to eql person.title
        expect(json[:employee_type]).to eql person.employee_type.to_s
        expect(json[:full_time]).to eql person.full_time
        expect(json[:pay_type]).to eql person.pay_type.to_s
      end
    end
  end

  describe 'GET /v1/people/by_id/:id' do
    # periods in the URL can be interpreted as extensions to test that they work specifically
    let!(:netid) { create :id, person: person, type: :netid, identifier: 'with.period' }
    let!(:biola_id) { create :id, person: person, type: :biola_id }

    let(:id) { netid }
    let(:url) { "/v1/people/by_id/#{id}" }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    context 'without a type' do
      it 'finds a person by netid' do
        expect(response.status).to eql 200
        expect(json[:last_name]).to eql person.last_name
      end
    end

    context 'with a type' do
      let(:id) { biola_id }
      let(:params) { {type: 'biola_id'} }

      it 'finds a person by id type' do
        expect(response.status).to eql 200
        expect(json[:uuid]).to eql person.uuid.to_s
      end
    end

    context 'with an bogus id' do
      it '404s' do
        signed_get url, type: 'biola_id' do |response|
          expect(response.status).to eql 404
        end
      end
    end

    context 'with an bogus type' do
      it '400s' do
        signed_get url, type: 'bogus' do |response|
          expect(response.status).to eql 400
        end
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
        residence: 'Strongbadia',
        floor: '1',
        wing: 'East',
        majors: ['Sadness'],
        privacy: 'true',
        department: 'Psychology',
        title: 'Total Bummer',
        employee_type: 'Full-Time',
        full_time: 'true',
        pay_type: '02'
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
        expect(creation.residence).to eql 'Strongbadia'
        expect(creation.floor).to eql 1
        expect(creation.wing).to eql 'East'
        expect(creation.majors).to eql ['Sadness']
        expect(creation.privacy).to eql true
        expect(creation.department).to eql 'Psychology'
        expect(creation.title).to eql 'Total Bummer'
        expect(creation.employee_type).to eql :'Full-Time'
        expect(creation.full_time).to eql true
        expect(creation.pay_type).to eql :'02'
      end
    end
  end

  describe 'PUT /v1/people/:id' do
    let(:person) { create :person, partial_ssn: '2345'}
    let(:method) { :put }
    let(:url) { "/v1/people/#{person_id}" }
    let(:params) { {partial_ssn: '6789'} }
    its(:status) { should eql 200 }
    it { expect { signed_put(url, params) }.to change { person.reload.partial_ssn }.from('2345').to '6789' }
  end
end
