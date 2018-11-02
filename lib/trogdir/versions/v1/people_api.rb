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
      end
    end
  end
end
