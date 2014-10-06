module Trogdir
  module V1
    class EmailEntity < Grape::Entity
      expose(:id) { |email| email.id.to_s }
      expose :type
      expose :address
      expose :primary
    end
  end
end
