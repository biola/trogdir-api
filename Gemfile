source 'https://rubygems.org'

gem 'api-auth', '1.4.1', require: 'api_auth'
gem 'grape', '0.7.0'
gem 'grape-entity', '0.4.4'
gem 'hashie-forbidden_attributes', '~> 0.1.1'
gem 'newrelic_rpm', '~> 3.15', '< 4'
gem 'oj', '~> 2.10'
gem 'pinglish', '~> 0.2.1'
gem 'puma', '~> 3.4'
# NOTE: beta1 fixes this issue https://github.com/railsconfig/rails_config/pull/86
gem 'rails_config', '~> 0.5.0.beta1'
gem 'rake', '~> 11.1'
gem 'trogdir_models', '~> 0.17.0'
gem 'turnout', '~> 2.3'

group :development, :test do
  gem 'factory_girl', '~> 4.7'
  gem 'faker', '~> 1.6'
  gem 'pry', '~> 0.10'
  gem 'pry-rescue', '~> 1.4'
  gem 'pry-stack_explorer', '~> 0.4'
  gem 'rack-test', '~> 0.6'
  gem 'rspec', '~> 3.4'
  gem 'rspec-its', '~> 1.2'
end

group :development do
  gem 'better_errors', '~> 2.1'
  gem 'binding_of_caller', '~> 0.7'
  gem 'shotgun', '~> 0.9'
end

group :production do
  gem 'sentry-raven'
end
