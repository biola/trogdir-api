module Trogdir
  module V1
    class PhotosAPI < Grape::API
      resource :photos do
        before do
          @person = Person.find_by(uuid: params[:person_id]) if params[:person_id]
          @photo = @person.photos.find(params[:photo_id]) if params[:photo_id]
        end

        get do
          present @person.photos, with: PhotoEntity
        end

        params do
          requires :photo_id, type: String
        end
        get ':photo_id' do
          present @photo, with: PhotoEntity
        end
      end
    end
  end
end
