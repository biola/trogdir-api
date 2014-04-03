module Trogdir
  module V1
    class PersonEntity < Grape::Entity
      expose :ids, using: IDEntity, as: :ids
      expose :emails, using: EmailEntity, as: :emails
      expose :photos, using: PhotoEntity, as: :photos
      expose :phones, using: PhoneEntity, as: :phones
      expose :addresses, using: AddressEntity, as: :addresses

      expose :uuid

      # Names
      expose :first_name
      expose :preferred_name
      expose :middle_name
      expose :last_name
      expose :display_name

      # Demographic
      expose :gender
      expose :partial_ssn
      expose :birth_date

      # Groups and permissions
      expose :entitlements
      expose :affiliations

      # Options
      expose :enabled

      # STUDENT INFO #

      # On-Campus Residence
      expose :residence
      expose :floor
      expose :wing

      # Academic
      expose :majors

      # FERPA
      expose :privacy

      # EMPLOYEE INFO #
      expose :department
      expose :title
      expose :employee_type
      expose :full_time
      expose :pay_type
    end
  end
end
