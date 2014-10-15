module Trogdir
  module V1
    class SyncLogWithChangesetEntity < Grape::Entity
      expose(:sync_log_id) { |sync_log| sync_log.id.to_s }
      expose(:action) { |sync_log| sync_log.changeset.action }
      expose(:person_id) { |sync_log| sync_log.changeset.person.uuid }
      expose(:affiliations) { |sync_log| sync_log.changeset.person.affiliations }
      expose(:scope) { |sync_log| sync_log.changeset.scope }
      expose(:original) { |sync_log| sync_log.changeset.original }
      expose(:modified) { |sync_log| sync_log.changeset.modified }
      expose(:created_at) { |sync_log| sync_log.changeset.created_at }
    end
  end
end
