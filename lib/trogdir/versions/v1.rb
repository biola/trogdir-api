module Trogdir
  module V1
    autoload :API, File.expand_path('../../../trogdir/versions/v1/api', __FILE__)
    autoload :PersonEntity, File.expand_path('../../../trogdir/versions/v1/entities/person', __FILE__)
    autoload :IDEntity, File.expand_path('../../../trogdir/versions/v1/entities/id', __FILE__)
    autoload :EmailEntity, File.expand_path('../../../trogdir/versions/v1/entities/email', __FILE__)
    autoload :PhotoEntity, File.expand_path('../../../trogdir/versions/v1/entities/photo', __FILE__)
    autoload :PhoneEntity, File.expand_path('../../../trogdir/versions/v1/entities/phone', __FILE__)
    autoload :AddressEntity, File.expand_path('../../../trogdir/versions/v1/entities/address', __FILE__)
  end
end