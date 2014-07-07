require 'new_relic/agent/instrumentation/rack'
require 'rack/turnout'

module Trogdir
  class API < Grape::API
    helpers ResponseHelpers
    format :json
    rescue_from :all

    use Rack::Turnout

    mount Trogdir::V1::API

    route(:any, '*path') { raise_404 }
    route(:any, '/') { raise_404 }

    include ::NewRelic::Agent::Instrumentation::Rack
  end
end
