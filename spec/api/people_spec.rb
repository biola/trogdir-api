require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.id }
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
      let!(:id) { create :id, person: person }
      let!(:email) { create :email, person: person }
      let!(:photo) { create :photo, person: person }
      let!(:phone) { create :phone, person: person }
      let!(:address) { create :address, person: person }

      it 'has expected values' do
        expect(json[:ids].first.symbolize_keys).to eql type: id.type.to_s, identifier: id.identifier
        expect(json[:emails].first.symbolize_keys).to eql type: email.type.to_s, address: email.address, primary: false
        expect(json[:photos].first.symbolize_keys).to eql type: photo.type.to_s, url: photo.url, height: photo.height, width: photo.width
        expect(json[:phones].first.symbolize_keys).to eql type: phone.type.to_s, number: phone.number
        expect(json[:addresses].first.symbolize_keys).to eql type: address.type.to_s, street_1: address.street_1, street_2: address.street_2, city: address.city, state: address.state, zip: address.zip, country: address.country

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
        expect(json[:privacy]).to eql person.privacy
        expect(json[:enabled]).to eql person.enabled
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
        expect(json[:_id]).to eql person._id.to_s
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

  describe 'GET /v1/people/:person_id/ids' do
    let(:url) { "/v1/people/#{person_id}/ids" }
    let!(:netid) { create :id, person: person, type: :netid }
    let!(:biola_id) { create :id, person: person, type: :biola_id, identifier: '0000000' }
    let(:id_id) { biola_id.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'type' => netid.type.to_s, 'identifier' => netid.identifier}, {'type' => biola_id.type.to_s, 'identifier' => biola_id.identifier}] }

    describe 'GET /v1/people/:person_id/ids/:id_id' do
      let(:url) { "/v1/people/#{person_id}/ids/#{id_id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql type: biola_id.type.to_s, identifier: biola_id.identifier }
    end

    describe 'POST /v1/people/:person_id/ids' do
      let(:method) { :post }
      let(:params) { {type: 'google_apps', identifier: 'the.cheat'} }
      its(:status) { should eql 201 }
      it { expect { signed_post(url, params) }.to change { person.reload.ids.count }.by 1 }
    end

    describe 'PUT /v1/people/:person_id/ids/:id_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/ids/#{id_id}" }
      let(:params) { {identifier: '1234567'} }
      its(:status) { should eql 200 }
      it { expect { signed_put(url, params) }.to change { biola_id.reload.identifier }.from('0000000').to '1234567' }
    end

    describe 'DELETE /v1/people/:person_id/ids/:id_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/ids/#{id_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.ids.count }.by -1 }
    end
  end

  describe 'GET /v1/people/:person_id/emails' do
    let(:url) { "/v1/people/#{person_id}/emails" }
    let!(:university) { create :email, person: person, type: :university, primary: true }
    let!(:personal) { create :email, person: person, type: :personal, address: 'trogdor@example.com' }
    let(:email_id) { personal.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'type' => university.type.to_s, 'address' => university.address, 'primary' => university.primary}, {'type' => personal.type.to_s, 'address' => personal.address, 'primary' => personal.primary}] }

    describe 'GET /v1/people/:person_id/emails/:email_id' do
      let(:url) { "/v1/people/#{person_id}/emails/#{personal.id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql type: personal.type.to_s, address: personal.address, primary: false }
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
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/emails/#{email_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.emails.count }.by -1 }
    end
  end

  describe 'GET /v1/people/:person_id/photos' do
    let(:url) { "/v1/people/#{person_id}/photos" }
    let!(:id_card) { create :photo, person: person }
    let(:photo_id) { id_card.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'type' => id_card.type.to_s, 'url' => id_card.url, 'height' => id_card.height, 'width' => id_card.width}] }
  end
end