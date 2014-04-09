module Trogdir
  module V1
    class AddressEntity < Grape::Entity
      expose :id
      expose :type
      expose :street_1
      expose :street_2
      expose :city
      expose :state
      expose :zip
      expose :country
    end
  end
end