module Trogdir
  module V1
    class GroupsAPI < Grape::API
      resource :groups do
        before do
          if params[:identifier]
            @person = if params[:type]
              elem_match_or_404 Person, ids: {type: params[:type], identifier: params[:identifier]}
            else
              Person.find_by uuid: params[:identifier]
            end
            @groups = Array(@person.groups)
          end
        end

        desc 'Get the people in a group'
        params do
          requires :group, type: String
        end
        get ':group/people' do
          people = Person.where(groups: params[:group])
          present people, with: PersonEntity, serializable: true
        end

        desc 'Add a person to a group'
        params do
          requires :group, type: String
          requires :identifier, type: String, desc: 'Person identifier'
          optional :type, type: Symbol, values: ID::TYPES, desc: 'Person identifier type'
        end
        put ':group/add' do
          @person.groups = (@groups + [params[:group]]).uniq

          {result: @person.save && @person.groups.length == @groups.length + 1}
        end

        desc 'Remove a person from a group'
        params do
          requires :group, type: String
          requires :identifier, type: String, desc: 'Person identifier'
          optional :type, type: Symbol, values: ID::TYPES, desc: 'Person identifier type'
        end
        put ':group/remove' do
          @person.groups = (@groups - [params[:group]]).uniq

          {result: @person.save && @person.groups.length == @groups.length - 1}
        end
      end
    end
  end
end
