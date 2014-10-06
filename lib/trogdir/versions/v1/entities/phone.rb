module Trogdir
  module V1
    class PhoneEntity < Grape::Entity
      expose(:id) { |phone| phone.id.to_s }
      expose :type
      expose :number
      expose :primary
    end
  end
end
