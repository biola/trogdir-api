require 'new_relic/agent/instrumentation/rack'

module Trogdir
  module V1
    class API < Grape::API
      version 'v1', using: :path

      format :json
      helpers RequestHelpers
      helpers ResponseHelpers
      helpers AuthenticationHelpers

      before { authenticate! }

      rescue_from Mongoid::Errors::DocumentNotFound do |e|
        error! "404 Not Found", 404
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

      include ::NewRelic::Agent::Instrumentation::Rack
    end
  end
end