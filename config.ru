require ::File.expand_path('../config/environment',  __FILE__)

if ENV['RACK_ENV'] == 'development'
  require 'newrelic_rpm'
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode

  require 'better_errors'
  use BetterErrors::Middleware
end

run Trogdir::API