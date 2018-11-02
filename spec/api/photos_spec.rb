require 'spec_helper'

describe Trogdir::API do
  include Rack::Test::Methods
  include HMACHelpers

  let(:person) { create :person }
  let(:person_id) { person.uuid }
  let(:method) { :get }
  let(:url) { "/v1/people/#{person_id}/photos" }
  let(:params) { {} }
  let(:response) { send "signed_#{method}".to_sym, url, params }
  let(:json) do
    js = JSON.parse(response.body)
    js = js.deep_symbolize_keys if js.respond_to? :deep_symbolize_keys
    js
  end

  subject { response }

  describe 'GET /v1/people/:person_id/photos' do
    let!(:id_card) { create :photo, person: person, width: 42 }
    let(:photo_id) { id_card.id }

    context 'when unauthenticated' do
      before { get url }
      subject { last_response }
      its(:status) { should eql 401 }
    end

    its(:status) { should eql 200 }
    it { expect(json).to eql [{'id' => id_card.id.to_s, 'type' => id_card.type.to_s, 'url' => id_card.url, 'height' => id_card.height, 'width' => id_card.width}] }

    describe 'GET /v1/people/:person_id/photos/:photo_id' do
      let(:url) { "/v1/people/#{person_id}/photos/#{id_card.id}" }
      its(:status) { should eql 200 }
      it { expect(json).to eql id: id_card.id.to_s, type: id_card.type.to_s, url: id_card.url, height: id_card.height, width: id_card.width }
    end
  end
end
