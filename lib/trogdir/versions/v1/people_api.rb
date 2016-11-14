module Trogdir
  module V1
    class PeopleAPI < Grape::API
      UUID_REGEXP = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

      resource :people do
        before do
          @person = Person.find_by(uuid: params[:person_id]) if params[:person_id]
        end

        desc 'Get a list of people'
        params do
          optional :affiliation, type: String
          optional :page, type: Integer
          optional :per_page, type: Integer, default: 100
        end
        get do
          conditions = {}

          conditions[:affiliations] = params[:affiliation].to_s if params[:affiliation]

          people = Person.where(conditions)
          if params[:page] && params[:per_page] && params[:page] > 0
            skip_count = params[:page] * params[:per_page] - params[:per_page]
            people = people.skip(skip_count).limit(params[:per_page])
          end

          present people, with: PersonEntity, serializable: true
        end

        desc 'Return a person by associated id', {params: PersonEntity.documentation.except(:enabled)}
        params do
          requires :identifier, type: String, desc: 'Associated identifier'
          optional :type, type: Symbol, values: ID::TYPES, default: ID::DEFAULT_TYPE
        end
        get 'by_id/:identifier', requirements: {identifier: /[0-9a-zA-Z\._-]+/} do
          conditions = {ids: {type: params[:type], identifier: params[:identifier]}}

          present elem_match_or_404(Person, conditions), with: PersonEntity
        end

        desc 'Return a person', {params: PersonEntity.documentation.except(:enabled)}
        params do
          requires :person_id, desc: 'Person ID'
        end
        get ':person_id', requirements: {person_id: UUID_REGEXP} do
          present @person, with: PersonEntity
        end

        desc 'Create a person'
        params do
          # Names
          requires :first_name, type: String
          optional :preferred_name, type: String
          optional :middle_name, type: String
          requires :last_name, type: String
          optional :display_name, type: String

          # Demographic
          optional :gender, type: Symbol, values: Person::GENDERS
          optional :partial_ssn, type: String
          optional :birth_date, type: Date

          # Groups and permissions
          optional :entitlements, type: Array
          optional :affiliations, type: Array
          optional :groups, type: Array

          # STUDENT INFO #

          # On-Campus Residence
          optional :residence, type: String
          optional :floor, type: Integer
          optional :wing, type: String
          optional :mailbox, type: String

          # Academic
          optional :majors, type: Array
          optional :minors, type: Array

          # FERPA
          optional :privacy, type: Boolean

          # EMPLOYEE INFO #
          optional :department, type: String
          optional :title, type: String
          optional :employee_type, type: Symbol
          optional :full_time, type: Boolean
          optional :pay_type, type: Symbol
          optional :job_ct, type: Integer
        end
        post do
          present Person.create!(clean_params), with: PersonEntity
        end

        desc 'Update a person'
        params do
          # Names
          optional :first_name, type: String
          optional :preferred_name, type: String
          optional :middle_name, type: String
          optional :last_name, type: String
          optional :display_name, type: String

          # Demographic
          optional :gender, type: Symbol, values: Person::GENDERS
          optional :partial_ssn, type: String
          optional :birth_date, type: Date

          # Groups and permissions
          optional :entitlements, type: Array
          optional :affiliations, type: Array
          optional :groups, type: Array

          # STUDENT INFO #

          # On-Campus Residence
          optional :residence, type: String
          optional :floor, type: Integer
          optional :wing, type: String
          optional :mailbox, type: String

          # Academic
          optional :majors, type: Array
          optional :minors, type: Array

          # FERPA
          optional :privacy, type: Boolean

          # EMPLOYEE INFO #
          optional :department, type: String
          optional :title, type: String
          optional :employee_type, type: Symbol
          optional :full_time, type: Boolean
          optional :pay_type, type: Symbol
          optional :job_ct, type: Integer
        end
        put ':person_id', requirements: {person_id: UUID_REGEXP} do
          @person.update_attributes! clean_params(except: :person_id)

          present @person, with: PersonEntity
        end
      end
    end
  end
end
