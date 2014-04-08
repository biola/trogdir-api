module Trogdir
  module V1
    class IDEntity < Grape::Entity
      expose :id
      expose :type
      expose :identifier
    end
  end
end