module Trogdir
  module V1
    class IDEntity < Grape::Entity
      expose :type
      expose :identifier
    end
  end
end