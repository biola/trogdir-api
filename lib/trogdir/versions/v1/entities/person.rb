module Trogdir
  module V1
    class PersonEntity < Grape::Entity
      FIELDS = [
        :uuid,

        # Names
        :first_name,
        :preferred_name,
        :middle_name,
        :last_name,
        :display_name,

        # Demographic
        :gender,
        :partial_ssn,
        :birth_date,

        # Groups and permissions
        :entitlements,
        :affiliations,

        # Options
        :enabled,

        # STUDENT INFO #

        # On-Campus Residence
        :residence,
        :floor,
        :wing,

        # Academic
        :majors,

        # FERPA
        :privacy,

        # EMPLOYEE INFO #
        :department,
        :title,
        :employee_type,
        :full_time,
        :pay_type,

        ids: [
          :id,
          :type,
          :identifier
        ],

        emails: [
          :id,
          :type,
          :address,
          :primary
        ],

        photos: [
          :id,
          :type,
          :url,
          :height,
          :width
        ],

        phones: [
          :id,
          :type,
          :number,
          :primary
        ],

        addresses: [
          :id,
          :type,
          :street_1,
          :street_2,
          :city,
          :state,
          :zip,
          :country
        ]
      ]

      def serializable_hash(runtime_options = {})
        build_hash(object, FIELDS)
      end

      private

      def build_hash(object, fields)
        fields.each_with_object({}) do |field, hash|
          if field.is_a? Hash
            field.each do |association, embed_fields|
              hash[association] = object.send(association).map do |embed|
                build_hash(embed, embed_fields)
              end
            end
          else
            hash[field] = object.send(field)
          end
        end
      end
    end
  end
end