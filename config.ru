require ::File.expand_path('../config/environment',  __FILE__)

env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

if env == 'development'
  require 'newrelic_rpm'
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode

  require 'better_errors'
  use BetterErrors::Middleware
end

file = File.new("./log/#{env}.log", 'a+')
file.sync = true
use Rack::CommonLogger, file

use Pinglish, &TrogdirAPI.pinglish_block

run Trogdir::API
