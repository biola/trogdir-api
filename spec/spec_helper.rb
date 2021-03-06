$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
$:.unshift File.expand_path(File.dirname(__FILE__))

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'rspec'
require 'rspec/its'
require 'rack/test'
require 'factory_girl'
require 'faker'
require 'trogdir_models'
require 'logger'
require 'pry'

require_relative '../lib/trogdir_api'
TrogdirAPI.initialize!

TrogdirModels.load_factories
FactoryGirl.find_definitions

Dir[File.expand_path('../support/*.rb', __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # Clean/Reset Mongoid DB prior to running each test.
  config.before(:each) do
    Mongoid.purge!
  end

  $logger = Logger.new("/dev/null")
end
