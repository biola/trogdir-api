module Trogdir
  module V1
    class IDsAPI < Grape::API
      resource :ids do
        get do
          present Person.find_by(uuid: params[:person_id]).ids, with: IDEntity
        end

        params do
          # Stupid name. I know. But you get the idea.
          requires :id_id, type: String
        end
        get ':id_id' do
          present Person.find_by(uuid: params[:person_id]).ids.find(params[:id_id]), with: IDEntity
        end

        params do
          requires :type, type: Symbol, values: ID::TYPES
          requires :identifier
        end
        post do
          Person.find_by(uuid: params[:person_id]).ids.create! clean_params(except: :person_id)
        end

        params do
          requires :id_id, type: String
          optional :type, type: Symbol, values: ID::TYPES
          optional :identifier
        end
        put ':id_id' do
          Person.find_by(uuid: params[:person_id]).ids.find(params[:id_id]).update_attributes! clean_params(except: [:person_id, :id_id])
        end

        params do
          requires :id_id, type: String
        end
        delete ':id_id' do
          Person.find_by(uuid: params[:person_id]).ids.find(params[:id_id]).destroy
        end
      end
    end
  end
end