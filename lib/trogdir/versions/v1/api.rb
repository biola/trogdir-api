module Trogdir
  module V1
    class API < Grape::API
      version 'v1', using: :path

      format :json
      helpers ResponseHelpers
      helpers AuthenticationHelpers

      rescue_from Mongoid::Errors::DocumentNotFound do |e|
        error! "404 Not Found", 404
      end

      resource :people do
        desc 'Return a person'
        params do
          requires :id, desc: 'Identifier'
          optional :type, type: Symbol, values: ID::TYPES, default: ID::DEFAULT_TYPE
        end
        get ':id', requirements: {id: /[0-9a-zA-Z\._-]+/} do
          authenticate!

          conditions = {ids: {type: params[:type], identifier: params[:id]}}

          present elem_match_or_404(Person, conditions), with: PersonEntity
        end
      end
    end
  end
end