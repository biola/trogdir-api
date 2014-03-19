module Trogdir
  module V1
    class PhoneEntity < Grape::Entity
      expose :type
      expose :number
    end
  end
end