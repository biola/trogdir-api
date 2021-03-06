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

    describe 'POST /v1/people/:person_id/photos' do
      let(:method) { :post }
      let(:params) { {type: 'id_card', url: 'http://example.com/photo.jpg', height: '42', width: '42'} }
      its(:status) { should eql 201 }
      it { expect { signed_post(url, params) }.to change { person.reload.photos.count }.by 1 }

      it 'creates a changeset' do
        expect { signed_post(url, params) }.to change { Changeset.count }.by 1
        expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
      end
    end

    describe 'PUT /v1/people/:person_id/photos/:photo_id' do
      let(:method) { :put }
      let(:url) { "/v1/people/#{person_id}/photos/#{photo_id}" }
      let(:params) { {width: '43'} }
      its(:status) { should eql 200 }
      it { expect { signed_put(url, params) }.to change { id_card.reload.width }.from(42).to 43 }

      it 'creates a changeset' do
        expect { signed_put(url, params) }.to change { Changeset.count }.by 1
        expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
      end
    end

    describe 'DELETE /v1/people/:person_id/photos/:photo_id' do
      let(:method) { :delete }
      let(:url) { "/v1/people/#{person_id}/photos/#{photo_id}" }
      its(:status) { should eql 200 }
      it { expect { signed_delete(url, params) }.to change { person.reload.photos.count }.by -1 }

      it 'creates a changeset' do
        expect { signed_delete(url, params) }.to change { Changeset.count }.by 1
        expect(person.changesets.asc(:created_at).last.created_by).to_not be_nil
      end
    end
  end
end
