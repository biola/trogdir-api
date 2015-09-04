module Trogdir
  module V1
    class WorkerEntity < Grape::Entity
      expose(:id) { |id| id.id.to_s }
      expose :name
      expose :scheduled_for
      expose :sidekiq_id
    end
  end
end
