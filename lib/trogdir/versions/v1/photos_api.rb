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

        params do
          requires :type, type: Symbol, values: Photo::TYPES
          requires :url, type: String
          optional :height, type: Integer
          optional :width, type: Integer
        end
        post do
          present @person.photos.create!(clean_params(except: :person_id)), with: PhotoEntity
        end

        params do
          requires :photo_id, type: String
          optional :type, type: Symbol, values: Photo::TYPES
          optional :url, type: String
          optional :height, type: Integer
          optional :width, type: Integer
        end
        put ':photo_id' do
          @photo.update_attributes! clean_params(except: [:person_id, :photo_id])

          present @photo, with: PhotoEntity
        end

        params do
          requires :photo_id, type: String
        end
        delete ':photo_id' do
          @photo.destroy

          present @photo, with: PhotoEntity
        end
      end
    end
  end
end