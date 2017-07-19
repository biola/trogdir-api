module Trogdir
  module V1
    class ChangeSyncsAPI < Grape::API
      resource :change_syncs do
        before do
          if params[:sync_log_id]
            @sync_log = SyncLog.find_through_parents(params[:sync_log_id])

            unauthorized! unless @sync_log.syncinator == current_syncinator
          end
        end

        desc "Return and starts change_syncs that haven't been started"
        params do
          optional :limit, type: Integer, default: 100
        end
        put :start do
          syncinator = current_syncinator
          changesets = syncinator.startable_changesets.limit(params[:limit])

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
          current_syncinator.error! @sync_log, params[:message]
        end

        desc "Return a sync_log and mark it as succeeded"
        params do
          requires :sync_log_id, type: String
          requires :action, type: String
          optional :message, type: String
        end
        put 'finish/:sync_log_id' do
          current_syncinator.finish! @sync_log, params[:action], params[:message]
        end
      end
    end
  end
end
