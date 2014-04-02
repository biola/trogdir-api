module Trogdir
  module V1
    class AddressesAPI < Grape::API
      resource :addresses do
        get do
          present Person.find_by(uuid: params[:person_id]).addresses, with: AddressEntity
        end

        params do
          requires :address_id, type: String
        end
        get ':address_id' do
          present Person.find_by(uuid: params[:person_id]).addresses.find(params[:address_id]), with: AddressEntity
        end

        params do
          requires :type, type: Symbol, values: Address::TYPES
          requires :street_1, type: String
          optional :street_1, type: String
          optional :city, type: String
          optional :state, type: String
          optional :zip, type: String
          optional :contry, type: String
        end
        post do
          Person.find_by(uuid: params[:person_id]).addresses.create! clean_params(except: :person_id)
        end

        params do
          requires :address_id, type: String
          optional :type, type: Symbol, values: Address::TYPES
          optional :street_1, type: String
          optional :street_1, type: String
          optional :city, type: String
          optional :state, type: String
          optional :zip, type: String
          optional :contry, type: String
        end
        put ':address_id' do
          Person.find_by(uuid: params[:person_id]).addresses.find(params[:address_id]).update_attributes! clean_params(except: [:person_id, :address_id])
        end

        params do
          requires :address_id, type: String
        end
        delete ':address_id' do
          Person.find_by(uuid: params[:person_id]).addresses.find(params[:address_id]).destroy
        end
      end
    end
  end
end