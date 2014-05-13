require ::File.expand_path('../config/environment',  __FILE__)

if ENV['RACK_ENV'] == 'development'
  require 'better_errors'
  use BetterErrors::Middleware
end

require 'newrelic_rpm'
NewRelic::Agent.manual_start

run Trogdir::API