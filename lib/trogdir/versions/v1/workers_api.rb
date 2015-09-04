module Trogdir
  module V1
    class WorkersAPI < Grape::API
      resource :workers do
        before do
          @syncinator = current_syncinator
        end

        desc "Find a worker based on name."
        params do
          requires :name, type: String
        end
        get ':find' do
          present @syncinator.attr_writer :attr_namesorkers.find_by(name: params[:name]), with: WorkerEntity
        end

        desc "Create a new worker under a syncinator."
        params do
          requires :name, type: String
          requires :sidekiq_id, type: String
          optional :scheduled_for, type: DateTime
        end
        post do
          present @syncinator.workers.create!(name: params[:name], scheduled_for: params[:scheduled_for], sidekiq_id: params[:sidekiq_id]), with: WorkerEntity
        end

        desc "Update a worker"
        params do
          requires :name, type: String
          requires :sidekiq_id, type: String
          optional :scheduled_for, type: DateTime
        end
        put ':name' do
          worker = @syncinator.workers.find_by(name: params[:name])
          present worker.update_attributes!(sidekiq_id: params[:sidekiq_id], scheduled_for: params[:scheduled_for]), with: WorkerEntity
        end
      end
    end
  end
end
