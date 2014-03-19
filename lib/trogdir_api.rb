require 'grape'
require 'grape-entity'
require 'trogdir_models'

module TrogdirAPI
  def self.initialize!
    ENV['RACK_ENV'] ||= 'development'

    Mongoid.load! File.expand_path('../../config/mongoid.yml',  __FILE__)
  end
end

module Trogdir
  autoload :ResponseHelpers, 'trogdir/helpers/response_helpers.rb'
  autoload :API, 'trogdir/api'
  autoload :V1, 'trogdir/versions/v1'
end