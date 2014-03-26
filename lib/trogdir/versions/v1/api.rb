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

            params do
              requires :type, type: Symbol, values: ID::TYPES
              requires :identifier
            end
            post do
              Person.find(params[:person_id]).ids.create! clean_params(except: :person_id)
            end

            params do
              requires :id_id, type: String
              optional :type, type: Symbol, values: ID::TYPES
              optional :identifier
            end
            put ':id_id' do
              Person.find(params[:person_id]).ids.find(params[:id_id]).update_attributes! clean_params(except: [:person_id, :id_id])
            end

            params do
              requires :id_id, type: String
            end
            delete ':id_id' do
              Person.find(params[:person_id]).ids.find(params[:id_id]).destroy
            end
          end

          resource :emails do
            get do
              present Person.find(params[:person_id]).emails, with: EmailEntity
            end

            params do
              requires :email_id, type: String
            end
            get ':email_id' do
              present Person.find(params[:person_id]).emails.find(params[:email_id]), with: EmailEntity
            end

            params do
              requires :type, type: Symbol, values: Email::TYPES
              requires :address, type: String
              optional :primary, type: Boolean
            end
            post do
              Person.find(params[:person_id]).emails.create! clean_params(except: :person_id)
            end

            params do
              requires :email_id, type: String
              optional :type, type: Symbol, values: Email::TYPES
              optional :address, type: String
              optional :primary, type: Boolean
            end
            put ':email_id' do
              Person.find(params[:person_id]).emails.find(params[:email_id]).update_attributes! clean_params(except: [:person_id, :email_id])
            end

            params do
              requires :email_id, type: String
            end
            delete ':email_id' do
              Person.find(params[:person_id]).emails.find(params[:email_id]).destroy
            end
          end

          resource :photos do
            get do
              present Person.find(params[:person_id]).photos, with: PhotoEntity
            end

            params do
              requires :photo_id, type: String
            end
            get ':photo_id' do
              present Person.find(params[:person_id]).photos.find(params[:photo_id]), with: PhotoEntity
            end

            params do
              requires :type, type: Symbol, values: Photo::TYPES
              requires :url, type: String
              optional :height, type: Integer
              optional :width, type: Integer
            end
            post do
              Person.find(params[:person_id]).photos.create! clean_params(except: :person_id)
            end

            params do
              requires :photo_id, type: String
              optional :type, type: Symbol, values: Photo::TYPES
              optional :url, type: String
              optional :height, type: Integer
              optional :width, type: Integer
            end
            put ':photo_id' do
              Person.find(params[:person_id]).photos.find(params[:photo_id]).update_attributes! clean_params(except: [:person_id, :photo_id])
            end

            params do
              requires :photo_id, type: String
            end
            delete ':photo_id' do
              Person.find(params[:person_id]).photos.find(params[:photo_id]).destroy
            end
          end

          resource :phones do
            get do
              present Person.find(params[:person_id]).phones, with: PhoneEntity
            end
          end
        end
      end
    end
  end
end