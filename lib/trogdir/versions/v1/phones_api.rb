module Trogdir
  module V1
    class PhonesAPI < Grape::API
      resource :phones do
        before do
          @person = Person.find_by(uuid: params[:person_id]) if params[:person_id]
          @phone = @person.phones.find(params[:phone_id]) if params[:phone_id]
        end

        get do
          present @person.phones, with: PhoneEntity
        end

        params do
          requires :phone_id, type: String
        end
        get ':phone_id' do
          present @phone, with: PhoneEntity
        end
      end
    end
  end
end
