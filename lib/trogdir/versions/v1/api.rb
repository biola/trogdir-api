module Trogdir
  module V1
    class API < Grape::API
      version 'v1', using: :path

      format :json
      helpers RequestHelpers
      helpers ResponseHelpers
      helpers AuthenticationHelpers

      rescue_from Mongoid::Errors::DocumentNotFound do |e|
        error! "404 Not Found", 404
      end

      resource :people do
        desc 'Return a person', {params: PersonEntity.documentation.except(:enabled)}
        params do
          requires :id, desc: 'Identifier'
          optional :type, type: Symbol, values: ID::TYPES, default: ID::DEFAULT_TYPE
        end
        get ':id', requirements: {id: /[0-9a-zA-Z\._-]+/} do
          authenticate!

          conditions = {ids: {type: params[:type], identifier: params[:id]}}

          present elem_match_or_404(Person, conditions), with: PersonEntity
        end

        desc 'Create a person'
        params do
          # Names
          requires :first_name, type: String
          optional :preferred_name, type: String
          optional :middle_name, type: String
          requires :last_name, type: String
          optional :display_name, type: String

          # Demographic
          optional :gender, type: Symbol, values: Person::GENDERS
          optional :partial_ssn, type: String
          optional :birth_date, type: Date

          # Groups and permissions
          optional :entitlements, type: Array
          optional :affiliations, type: Array

          # Options
          optional :privacy, type: Boolean
        end
        post do
          authenticate!

          Person.create! clean_params
        end
      end
    end
  end
end