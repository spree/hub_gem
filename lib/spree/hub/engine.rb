module Spree
  module Hub
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_hub_client'

      initializer "spree.hub.environment", :before => :load_config_initializers do |app|
        Spree::Hub::Config = Spree::HubConfiguration.new
      end

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), "../../../app/**/*_decorator*.rb")) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end
      config.to_prepare &method(:activate).to_proc

      def self.root
        @root ||= Pathname.new(File.expand_path('../../../../', __FILE__))
      end
    end
  end
end
