require 'bundler'
Bundler.setup :default, ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :development

require_relative '../lib/trogdir_api'
TrogdirAPI.initialize!
