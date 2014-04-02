module Trogdir
  module V1
    class PhonesAPI < Grape::API
      resource :phones do
        get do
          present Person.find_by(uuid: params[:person_id]).phones, with: PhoneEntity
        end

        params do
          requires :phone_id, type: String
        end
        get ':phone_id' do
          present Person.find_by(uuid: params[:person_id]).phones.find(params[:phone_id]), with: PhoneEntity
        end

        params do
          requires :type, type: Symbol, values: Phone::TYPES
          requires :number, type: String
          optional :primary, type: Boolean
        end
        post do
          Person.find_by(uuid: params[:person_id]).phones.create! clean_params(except: :person_id)
        end

        params do
          requires :phone_id, type: String
          optional :type, type: Symbol, values: Phone::TYPES
          optional :number, type: String
          optional :primary, type: Boolean
        end
        put ':phone_id' do
          Person.find_by(uuid: params[:person_id]).phones.find(params[:phone_id]).update_attributes! clean_params(except: [:person_id, :phone_id])
        end

        params do
          requires :phone_id, type: String
        end
        delete ':phone_id' do
          Person.find_by(uuid: params[:person_id]).phones.find(params[:phone_id]).destroy
        end
      end
    end
  end
end