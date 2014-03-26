module Trogdir
  module V1
    class PhotosAPI < Grape::API
      resource :photos do
        get do
          present Person.find(params[:person_id]).photos, with: PhotoEntity
        end

        params do
          requires :photo_id, type: String
        end
        get ':photo_id' do
          present Person.find(params[:person_id]).photos.find(params[:photo_id]), with: PhotoEntity
        end

        params do
          requires :type, type: Symbol, values: Photo::TYPES
          requires :url, type: String
          optional :height, type: Integer
          optional :width, type: Integer
        end
        post do
          Person.find(params[:person_id]).photos.create! clean_params(except: :person_id)
        end

        params do
          requires :photo_id, type: String
          optional :type, type: Symbol, values: Photo::TYPES
          optional :url, type: String
          optional :height, type: Integer
          optional :width, type: Integer
        end
        put ':photo_id' do
          Person.find(params[:person_id]).photos.find(params[:photo_id]).update_attributes! clean_params(except: [:person_id, :photo_id])
        end

        params do
          requires :photo_id, type: String
        end
        delete ':photo_id' do
          Person.find(params[:person_id]).photos.find(params[:photo_id]).destroy
        end
      end
    end
  end
end