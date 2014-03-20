require ::File.expand_path('../config/environment',  __FILE__)

if ENV['RACK_ENV'] == 'development'
  require 'better_errors'
  use BetterErrors::Middleware
end

run Trogdir::API