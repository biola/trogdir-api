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
      end
    end
  end
end
