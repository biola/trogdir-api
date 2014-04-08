module Trogdir
  module V1
    class EmailsAPI < Grape::API
      resource :emails do
        before do
          @person = Person.find_by(uuid: params[:person_id]) if params[:person_id]
          @email = @person.emails.find(params[:email_id]) if params[:email_id]
        end

        get do
          present @person.emails, with: EmailEntity
        end

        params do
          requires :email_id, type: String
        end
        get ':email_id' do
          present @email, with: EmailEntity
        end

        params do
          requires :type, type: Symbol, values: Email::TYPES
          requires :address, type: String
          optional :primary, type: Boolean
        end
        post do
          present @person.emails.create!(clean_params(except: :person_id)), with: EmailEntity
        end

        params do
          requires :email_id, type: String
          optional :type, type: Symbol, values: Email::TYPES
          optional :address, type: String
          optional :primary, type: Boolean
        end
        put ':email_id' do
          @email.update_attributes! clean_params(except: [:person_id, :email_id])

          present @email, with: EmailEntity
        end

        params do
          requires :email_id, type: String
        end
        delete ':email_id' do
          @email.destroy

          present @email, with: EmailEntity
        end
      end
    end
  end
end