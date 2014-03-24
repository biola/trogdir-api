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

      resource :people do
        desc 'Return a person by associated id', {params: PersonEntity.documentation.except(:enabled)}
        params do
          requires :identifier, desc: 'Associated identifier'
          optional :type, type: Symbol, values: ID::TYPES, default: ID::DEFAULT_TYPE
        end
        get 'by_id/:identifier', requirements: {identifier: /[0-9a-zA-Z\._-]+/} do
          conditions = {ids: {type: params[:type], identifier: params[:identifier]}}

          present elem_match_or_404(Person, conditions), with: PersonEntity
        end

        desc 'Return a person', {params: PersonEntity.documentation.except(:enabled)}
        params do
          requires :person_id, desc: 'Person ID'
        end
        get ':person_id', requirements: {person_id: /[0-9a-f]{24}/} do
          present Person.find(params[:person_id]), with: PersonEntity
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
          Person.create! clean_params
        end

        desc 'Update a person'
        params do
          # Names
          optional :first_name, type: String
          optional :preferred_name, type: String
          optional :middle_name, type: String
          optional :last_name, type: String
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
        put do
          Person.create! clean_params
        end

        resource ':person_id' do
          resource :ids do
            get do
              present Person.find(params[:person_id]).ids, with: IDEntity
            end

            params do
              # Stupid name. I know. But you get the idea.
              requires :id_id, type: String
            end
            get ':id_id' do
              present Person.find(params[:person_id]).ids.find(params[:id_id]), with: IDEntity
            end
          end
        end
      end
    end
  end
end