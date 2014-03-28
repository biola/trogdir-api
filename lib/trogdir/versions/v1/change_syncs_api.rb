module Trogdir
  module V1
    class ChangeSyncsAPI < Grape::API
      resource :change_syncs do
        desc "Return and starts change_syncs that haven't been started"
        put :start do
          syncinator = current_syncinator
          changesets = syncinator.startable_changesets

          sync_logs = changesets.map do |changeset|
            syncinator.start! changeset
          end

          present sync_logs, with: SyncLogWithChangesetEntity
        end

        desc "Return a sync_log and mark it as errored"
        params do
          requires :sync_log_id, type: String
          requires :message, type: String
        end
        put 'error/:sync_log_id' do
          sync_log = SyncLog.find_through_parents(params[:sync_log_id])

          current_syncinator.error! sync_log, params[:message]
        end

        desc "Return a sync_log and mark it as succeeded"
        params do
          requires :sync_log_id, type: String
          requires :action, type: String
          optional :message, type: String
        end
        put 'finish/:sync_log_id' do
          sync_log = SyncLog.find_through_parents(params[:sync_log_id])

          current_syncinator.finish! sync_log, params[:action], params[:message]
        end
      end
    end
  end
end