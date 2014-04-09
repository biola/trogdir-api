module Trogdir
  module V1
    class PhoneEntity < Grape::Entity
      expose :id
      expose :type
      expose :number
      expose :primary
    end
  end
end