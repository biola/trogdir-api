require 'grape'
require 'grape-entity'
require 'hashie-forbidden_attributes'
require 'oj'
require 'api_auth'
require 'config'
require 'trogdir_models'
require 'turnout'

module TrogdirAPI
  def self.environment
    (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || :development).to_sym
  end

  def self.initialize!
    ENV['RACK_ENV'] ||= environment.to_s

    Config.load_and_set_settings('./config/settings.yml', "./config/settings.#{environment}.yml", './config/settings.local.yml')

    MultiJson.use :oj

    mongoid_yml_path = File.expand_path('../../config/mongoid.yml',  __FILE__)
    mongoid_yml_path = "#{mongoid_yml_path}.example" if !File.exists? mongoid_yml_path
    Mongoid.load! mongoid_yml_path
    Mongoid.logger.level = Logger::DEBUG

    if defined? Raven
      Raven.configure do |config|
        config.dsn = Settings.sentry.url
      end
    end

    Turnout.configure do |config|
      config.named_maintenance_file_paths.merge! server: '/tmp/turnout.yml'
      config.default_maintenance_page = Turnout::MaintenancePage::JSON
    end

    require File.expand_path('../trogdir_api/pinglish', __FILE__)
  end
end

module Trogdir
  autoload :AuthenticationHelpers, File.expand_path('../trogdir/helpers/authentication_helpers', __FILE__)
  autoload :ResponseHelpers, File.expand_path('../trogdir/helpers/response_helpers', __FILE__)
  autoload :RequestHelpers, File.expand_path('../trogdir/helpers/request_helpers', __FILE__)
  autoload :API, File.expand_path('../trogdir/api', __FILE__)
  autoload :V1, File.expand_path('../trogdir/versions/v1', __FILE__)
end
