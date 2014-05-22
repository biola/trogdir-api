require 'new_relic/agent/instrumentation/rack'

module Trogdir
  class API < Grape::API
    mount Trogdir::V1::API

    include ::NewRelic::Agent::Instrumentation::Rack
  end
end