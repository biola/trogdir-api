module Trogdir
  module V1
    class AccountEntity < Grape::Entity
      expose(:id) { |account| account.id.to_s }
      expose(:person_id) { |account| account.person_id.to_s }
      expose :_type
      expose :modified_by
      expose :confirmation_key
      expose :confirmed_at
    end
  end
end
