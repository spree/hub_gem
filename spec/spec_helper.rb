require 'simplecov'
SimpleCov.start do

  add_group 'Models', '/app/models/'
  add_group 'Controllers', '/app/controllers/'
  add_group 'Serializers', '/app/serializers/'
  add_group "Hub", '/lib/spree/hub/'
  add_group 'Handlers', '/lib/spree/hub/handler/'

  add_filter '/spec/'

  project_name 'Webhooks and Push API implemention for the Spree Commerce Hub'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

begin
  require File.expand_path("../dummy/config/environment", __FILE__)
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
  exit
end

require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
require 'ffaker'
require 'hub/samples'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

require 'spree/testing_support/factories'
require 'spree/testing_support/preferences'
require 'spree/testing_support/controller_requests'

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [/gems\/activesupport/, /gems\/actionpack/, /gems\/rspec/]
  config.color = true

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::Preferences, :type => :controller
  config.include Spree::TestingSupport::ControllerRequests, :type => :controller

  config.fail_fast = ENV['FAIL_FAST'] || false

  config.use_transactional_fixtures = true
  config.before do
    Spree::Hub::Config[:hub_store_id] = "234254as3423r3243"
    Spree::Hub::Config[:hub_token] = "abc1233"
  end
end



class Spree::Hub::Handler::AddOrderHandler < Spree::Hub::Handler::Base
  def process
    response "Order added!"
  end
end
