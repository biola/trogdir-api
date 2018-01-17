module Trogdir
  module V1
    class AccountsAPI < Grape::API
      resource :accounts do
        before do
          if params[:person_id]
            @person = Person.find_by(uuid: params[:person_id])
          end

          if params[:account_id]
            @account = @person.accounts.find(params[:account_id])
          end
        end

        get do
          present @person.accounts, with: AccountEntity
        end

        params do
          requires :account_id, type: String
        end
        get ':account_id' do
          present @account, with: AccountEntity
        end

        params do
          requires :_type, type: String, values: Account::TYPES
        end
        post do
          # Because account is the superclass one cannot create a subclass just
          # by setting _type. Thus we need to create the desired account from an
          # account type whitelist.
          params['person_id'] = @person.id.to_s
          type = Account::TYPES.grep(params[:_type]).first
          account = @person.accounts << type.safe_constantize.create!(
            clean_params(except: :person_id)
          )
          # TODO: finish trying to set person on creation so as not to create
          # another history track
          # params['person_id'] = @person.id
          # type = Account::TYPES.grep(params[:_type]).first
          # account = type.safe_constantize.create!(clean_params)

          present account, with: AccountEntity
        end

        params do
          requires :account_id, type: String
          optional :_type, type: String, values: Account::TYPES
          optional :modified_by, type: String
          optional :confirmation_key, type: String
          optional :confirmed_at, type: String
        end
        put ':account_id' do
          @account.update_attributes!(
            clean_params(except: %i[person_id account_id])
          )
        end

        params do
          requires :account_id, type: String
        end
        delete ':account_id' do
          @account.destroy

          present @account, with: AccountEntity
        end
      end
    end
  end
end
