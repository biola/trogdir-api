require 'bundler'
Bundler.setup :default, ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :developement

require_relative '../lib/trogdir_api'
TrogdirAPI.initialize!