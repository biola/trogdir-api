module Trogdir
  class API < Grape::API
    mount Trogdir::V1::API
  end
end