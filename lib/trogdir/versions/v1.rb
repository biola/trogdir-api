module Trogdir
  module V1
    autoload :API, 'trogdir/versions/v1/api'
    autoload :PersonEntity, 'trogdir/versions/v1/entities/person'
    autoload :IDEntity, 'trogdir/versions/v1/entities/id'
    autoload :EmailEntity, 'trogdir/versions/v1/entities/email'
    autoload :PhotoEntity, 'trogdir/versions/v1/entities/photo'
    autoload :PhoneEntity, 'trogdir/versions/v1/entities/phone'
    autoload :AddressEntity, 'trogdir/versions/v1/entities/address'
  end
end