module Trogdir
  module V1
    class AddressesAPI < Grape::API
      resource :addresses do
        before do
          @person = Person.find_by(uuid: params[:person_id]) if params[:person_id]
          @address = @person.addresses.find(params[:address_id]) if params[:address_id]
        end

        get do
          present @person.addresses, with: AddressEntity
        end

        params do
          requires :address_id, type: String
        end
        get ':address_id' do
          present @address, with: AddressEntity
        end

        params do
          requires :type, type: Symbol, values: Address::TYPES
          requires :street_1, type: String
          optional :street_2, type: String
          optional :city, type: String
          optional :state, type: String
          optional :zip, type: String
          optional :country, type: String
        end
        post do
          present @person.addresses.create!(clean_params(except: :person_id)), with: AddressEntity
        end

        params do
          requires :address_id, type: String
          optional :type, type: Symbol, values: Address::TYPES
          optional :street_1, type: String
          optional :street_2, type: String
          optional :city, type: String
          optional :state, type: String
          optional :zip, type: String
          optional :country, type: String
        end
        put ':address_id' do
          @address.update_attributes! clean_params(except: [:person_id, :address_id])

          present @address, with: AddressEntity
        end

        params do
          requires :address_id, type: String
        end
        delete ':address_id' do
          @address.destroy

          present @address, with: AddressEntity
        end
      end
    end
  end
end
