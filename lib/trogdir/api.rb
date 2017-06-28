require 'rack/turnout'

module Trogdir
  class API < Grape::API
    helpers ResponseHelpers
    format :json

    rescue_from :all do |e|
      $logger.error("\n#{e.message} at #{e.backtrace.join(' ')}\n")
      error = { error: e.message }.to_json
      Rack::Response.new([ error ], 500, { 'Content-type' => 'application/json' }).finish
    end

    use Rack::Turnout

    mount Trogdir::V1::API

    route(:any, '*path') { raise_404 }
    route(:any, '/') { raise_404 }
  end
end
