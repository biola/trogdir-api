module Trogdir
  module V1
    class IDEntity < Grape::Entity
      expose(:id) { |id| id.id.to_s }
      expose :type
      expose :identifier
    end
  end
end
