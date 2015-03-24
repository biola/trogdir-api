lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'trogdir_api/version'

spec = Gem::Specification.new do |s|
  s.name = 'trogdir_api'
  s.version = TrogdirAPI::VERSION
  s.summary = 'Trogdir directory API'
  s.description = 'API for the Trogdir directory project'
  s.files = Dir['README.*', 'MIT-LICENSE', 'config.ru', 'config/*', 'lib/**/*.rb']
  s.require_path = 'lib'
  s.author = 'Adam Crownoble'
  s.email = 'adam.crownoble@biola.edu'
  s.homepage = 'https://github.com/biola/trogdir-api'
  s.license = 'MIT'
  s.add_dependency 'api-auth', '~> 1.0'
  s.add_dependency 'grape', '~> 0.6'
  s.add_dependency 'grape-entity', '~> 0.4'
  s.add_dependency 'hashie-forbidden_attributes', '~> 0.1'
  s.add_dependency 'trogdir_models'
  s.add_dependency 'oj'
  s.add_dependency 'turnout'
  s.add_dependency 'pinglish'
  s.add_dependency 'newrelic_rpm'
end
