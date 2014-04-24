require 'grape'
require 'grape-entity'
require 'oj'
require 'api_auth'
require 'trogdir_models'

module TrogdirAPI
  def self.initialize!
    ENV['RACK_ENV'] ||= 'development'

    MultiJson.use :oj

    mongoid_yml_path = File.expand_path('../../config/mongoid.yml',  __FILE__)
    mongoid_yml_path = "#{mongoid_yml_path}.example" if !File.exists? mongoid_yml_path
    Mongoid.load! mongoid_yml_path
  end
end

module Trogdir
  autoload :AuthenticationHelpers, File.expand_path('../trogdir/helpers/authentication_helpers', __FILE__)
  autoload :ResponseHelpers, File.expand_path('../trogdir/helpers/response_helpers', __FILE__)
  autoload :RequestHelpers, File.expand_path('../trogdir/helpers/request_helpers', __FILE__)
  autoload :API, File.expand_path('../trogdir/api', __FILE__)
  autoload :V1, File.expand_path('../trogdir/versions/v1', __FILE__)
end
