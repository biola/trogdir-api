require 'logger'
require ::File.expand_path('../config/environment',  __FILE__)

env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

if env == 'development'
  require 'better_errors'
  use BetterErrors::Middleware
end

file = File.new("./log/#{env}.log", 'a+')
file.sync = true

# create a global logger that we can use in the app
::Logger.class_eval { alias :write :'<<' }
$logger = ::Logger.new(file)

# use the same logger for rack logging
use Rack::CommonLogger, $logger

require 'pinglish'
pinglish_path = "#{ENV['PUMA_RELATIVE_URL_ROOT']}/_ping"
use Pinglish, { path: pinglish_path }, &TrogdirAPI.pinglish_block

map ENV['PUMA_RELATIVE_URL_ROOT'] || '/' do
  run Trogdir::API
end
