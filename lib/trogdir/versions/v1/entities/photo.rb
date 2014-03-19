module Trogdir
  module V1
    class PhotoEntity < Grape::Entity
      expose :type
      expose :url
      expose :height
      expose :width
    end
  end
end