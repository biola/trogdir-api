module Trogdir
  module V1
    class ChangesAPI < Grape::API
      resource :change_syncs do
        desc "Return and starts change_syncs that haven't been started"
        put :start do
          syncinator = current_syncinator
          changesets = syncinator.startable_changesets

          sync_logs = changesets.map do |changeset|
            syncinator.start! changeset
          end

          present sync_logs, with: SyncLogEntity
        end
      end
    end
  end
end