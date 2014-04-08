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

        params do
          requires :type, type: Symbol, values: Phone::TYPES
          requires :number, type: String
          optional :primary, type: Boolean
        end
        post do
          present @person.phones.create!(clean_params(except: :person_id)), with: PhoneEntity
        end

        params do
          requires :phone_id, type: String
          optional :type, type: Symbol, values: Phone::TYPES
          optional :number, type: String
          optional :primary, type: Boolean
        end
        put ':phone_id' do
          @phone.update_attributes! clean_params(except: [:person_id, :phone_id])

          present @phone, with: PhoneEntity
        end

        params do
          requires :phone_id, type: String
        end
        delete ':phone_id' do
          @phone.destroy

          present @phone, with: PhoneEntity
        end
      end
    end
  end
end