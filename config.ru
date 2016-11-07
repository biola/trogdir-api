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

require 'pinglish'
use Pinglish do |ping|
  ping.check :mongodb do
    Mongoid.default_client.command(ping: 1).documents.any?{|d| d == {'ok' => 1}}
  end
end

map ENV['PUMA_RELATIVE_URL_ROOT'] || '/' do
  run Trogdir::API
end
