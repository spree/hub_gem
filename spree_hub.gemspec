# encoding: UTF-8
Gem::Specification.new do |gem|
  gem.authors       = ["Peter Berkenbosch"]
  gem.email         = ["peter@spreecommerce.com"]
  gem.summary       = "Webhooks and Push API implemention for the Spree Commerce Hub"
  gem.description   = gem.summary
  gem.homepage      = "http://spreecommerce.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spree_hub"
  gem.require_paths = ["lib"]
  gem.version       = '2.3.0.beta'

  gem.add_dependency 'spree_core'
  gem.add_dependency 'active_model_serializers', '0.9.0.alpha1'
  gem.add_dependency 'httparty'

  gem.add_development_dependency 'capybara', '~> 2.1'
  gem.add_development_dependency 'coffee-rails'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'factory_girl', '~> 4.4'
  gem.add_development_dependency 'ffaker'
  gem.add_development_dependency 'rspec-rails',  '~> 2.13'
  gem.add_development_dependency 'sass-rails'
  gem.add_development_dependency 'selenium-webdriver'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'sqlite3'

end
