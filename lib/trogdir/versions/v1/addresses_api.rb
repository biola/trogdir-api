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
      end
    end
  end
end
