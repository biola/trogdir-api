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
      end
    end
  end
end
