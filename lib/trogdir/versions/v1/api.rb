module Trogdir
  module V1
    class API < Grape::API
      use ApiNewRelicInstrumenter

      version 'v1', using: :path

      format :json
      helpers RequestHelpers
      helpers ResponseHelpers
      helpers AuthenticationHelpers

      before { authenticate! }

      rescue_from Mongoid::Errors::DocumentNotFound do |e|
        Rack::Response.new([{error: '404 Not Found'}.to_json], 404, {'Content-type' => 'application/json'})
      end

      mount PeopleAPI
      mount ChangeSyncsAPI

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