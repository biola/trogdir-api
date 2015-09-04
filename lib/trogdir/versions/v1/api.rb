module Trogdir
  module V1
    class API < Grape::API
      use ApiNewRelicInstrumenter

      version 'v1', using: :path

      helpers RequestHelpers
      helpers AuthenticationHelpers

      before do
        authenticate!
        Syncinator.current = current_syncinator
      end

      rescue_from Mongoid::Errors::DocumentNotFound do |e|
        Rack::Response.new([{error: '404 Not Found'}.to_json], 404, {'Content-type' => 'application/json'})
      end

      mount PeopleAPI
      mount GroupsAPI
      mount ChangeSyncsAPI
      mount WorkersAPI

      resource 'people/:person_id' do
        mount IDsAPI
        mount EmailsAPI
        mount PhotosAPI
        mount PhonesAPI
        mount AddressesAPI
      end
    end
  end
end
