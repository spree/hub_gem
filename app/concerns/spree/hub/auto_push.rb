require 'active_support/concern'
require 'active_model/array_serializer'

module Spree
  module Hub
    module AutoPush
      extend ActiveSupport::Concern

      included do
        class << self
          attr_accessor :hub_serializer, :json_root_name, :push_when
        end

        after_commit :push_to_hub, if: -> obj { obj.pushable? }

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

        def pushable?
          return unless Spree::Hub::Config[:enable_auto_push]

          if push_condition = self.class.push_when
            push_condition.call(self)
          end
        end

      end
    end
  end
end
