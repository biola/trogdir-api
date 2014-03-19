require 'grape'
require 'grape-entity'
require 'trogdir_models'

module TrogdirAPI
  def self.initialize!
    ENV['RACK_ENV'] ||= 'development'

    mongoid_yml_path = File.expand_path('../../config/mongoid.yml',  __FILE__)
    mongoid_yml_path = "#{mongoid_yml_path}.example" if !File.exists? mongoid_yml_path
    Mongoid.load! mongoid_yml_path
  end
end

module Trogdir
  autoload :ResponseHelpers, 'trogdir/helpers/response_helpers.rb'
  autoload :API, 'trogdir/api'
  autoload :V1, 'trogdir/versions/v1'
end