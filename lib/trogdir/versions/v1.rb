module Trogdir
  module V1
    autoload :API, File.expand_path('../v1/api', __FILE__)
    autoload :ChangeSyncsAPI, File.expand_path('../v1/change_syncs_api', __FILE__)
    autoload :PeopleAPI, File.expand_path('../v1/people_api', __FILE__)
    autoload :IDsAPI, File.expand_path('../v1/ids_api', __FILE__)
    autoload :EmailsAPI, File.expand_path('../v1/emails_api', __FILE__)
    autoload :PhotosAPI, File.expand_path('../v1/photos_api', __FILE__)
    autoload :PhonesAPI, File.expand_path('../v1/phones_api', __FILE__)
    autoload :AddressesAPI, File.expand_path('../v1/addresses_api', __FILE__)
    autoload :SyncLogEntity, File.expand_path('../v1/entities/sync_log', __FILE__)
    autoload :SyncLogWithChangesetEntity, File.expand_path('../v1/entities/sync_log_with_changeset', __FILE__)
    autoload :PersonEntity, File.expand_path('../v1/entities/person', __FILE__)
    autoload :IDEntity, File.expand_path('../v1/entities/id', __FILE__)
    autoload :EmailEntity, File.expand_path('../v1/entities/email', __FILE__)
    autoload :PhotoEntity, File.expand_path('../v1/entities/photo', __FILE__)
    autoload :PhoneEntity, File.expand_path('../v1/entities/phone', __FILE__)
    autoload :AddressEntity, File.expand_path('../v1/entities/address', __FILE__)
  end
end