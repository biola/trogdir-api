module Trogdir
  module V1
    class EmailsAPI < Grape::API
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
    end
  end
end