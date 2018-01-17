module Trogdir
  module V1
    class API < Grape::API
      version 'v1', using: :path

      helpers RequestHelpers
      helpers AuthenticationHelpers

      before do
        # Verify HMAC signiture for the given request
        authenticate!

        # Mongoid::Userstamp::User gets mixed into the Syncinator class
        # which provides methods for setting the current syncinator for
        # the each request
        Syncinator.current = current_syncinator
      end

      rescue_from Mongoid::Errors::DocumentNotFound do |e|
        Rack::Response.new([{error: '404 Not Found'}.to_json], 404, {'Content-type' => 'application/json'})
      end

      mount PeopleAPI
      mount GroupsAPI
      mount ChangeSyncsAPI

      resource 'people/:person_id' do
        mount AccountsAPI
        mount AddressesAPI
        mount EmailsAPI
        mount IDsAPI
        mount PhonesAPI
        mount PhotosAPI
      end
    end
  end
end
