module Trogdir
  module V1
    class EmailEntity < Grape::Entity
      expose :type
      expose :address
      expose :primary
    end
  end
end