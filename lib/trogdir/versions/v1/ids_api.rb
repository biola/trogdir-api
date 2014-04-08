module Trogdir
  module V1
    class IDsAPI < Grape::API
      resource :ids do
        before do
          @person = Person.find_by(uuid: params[:person_id])
          @id = @person.ids.find(params[:id_id]) if params[:id_id]
        end

        get do
          present @person.ids, with: IDEntity
        end

        params do
          # Stupid name. I know. But you get the idea.
          requires :id_id, type: String
        end
        get ':id_id' do
          present @id, with: IDEntity
        end

        params do
          requires :type, type: Symbol, values: ID::TYPES
          requires :identifier
        end
        post do
          present @person.ids.create!(clean_params(except: :person_id)), with: IDEntity
        end

        params do
          requires :id_id, type: String
          optional :type, type: Symbol, values: ID::TYPES
          optional :identifier
        end
        put ':id_id' do
          @id.update_attributes! clean_params(except: [:person_id, :id_id])

          present @id, with: IDEntity
        end

        params do
          requires :id_id, type: String
        end
        delete ':id_id' do
          @id.destroy

          present @id, with: IDEntity
        end
      end
    end
  end
end