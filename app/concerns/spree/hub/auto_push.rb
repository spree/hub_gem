require 'active_support/concern'

module Spree
  module Hub
    module AutoPush
      extend ActiveSupport::Concern

      included do
        class << self
          attr_accessor :hub_serializer, :json_root_name
        end

        after_commit :push_to_hub, :if => Proc.new { Spree::Hub::Config[:enable_auto_push] }

        def push_to_hub
          Spree::Hub::Client.push(serialized_payload)
        end

        def serialized_payload
          ActiveModel::ArraySerializer.new(
            [self],
            each_serializer: self.class.hub_serializer.constantize,
            root: self.class.json_root_name
          ).to_json
        end

      end
    end
  end
end
