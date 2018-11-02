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
      end
    end
  end
end
