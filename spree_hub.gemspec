# encoding: UTF-8
version = File.read(File.expand_path("../../SPREE_VERSION", __FILE__)).strip

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
  gem.version       = version

  gem.add_dependency 'spree_core', version
  gem.add_dependency 'active_model_serializers', '0.9.0.alpha1'

end
