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
          begin
            syncinator = current_syncinator
            changesets = syncinator.startable_changesets.limit(params[:limit])
            changeset_count = changesets.count

            inner_total_time = 0
            start_time = Time.now
            ctr = 0
            sync_logs = changesets.map do |changeset|
              ctr += 1
              st = Time.now
              sync = syncinator.start! changeset
              inner_total_time += Time.now - st
              sync
            end

            present sync_logs, with: SyncLogWithChangesetEntity
          rescue StandardError
            end_time = Time.now
            total_time = end_time - start_time
            $logger.info "processing  #{changeset_count} changesets for #{syncinator.name}:outer processing time: #{total_time} secs. inner processing time: #{inner_total_time}. Processing ended at changeset # #{ctr}. Average time per changeset is #{inner_total_time / ctr} secs"
            raise
          end
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
