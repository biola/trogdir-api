module Trogdir
  module V1
    class PhotoEntity < Grape::Entity
      expose(:id) { |photo| photo.id.to_s }
      expose :type
      expose :url
      expose :height
      expose :width
    end
  end
end
