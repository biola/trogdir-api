module Trogdir
  module V1
    class SyncLogEntity < Grape::Entity
      expose(:sync_log_id) { |sync_log| sync_log.id }
      expose :started_at
      expose :errored_at
      expose :succeeded_at
      expose :action
      expose :message
    end
  end
end