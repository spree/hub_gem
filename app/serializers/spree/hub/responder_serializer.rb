require 'active_model/serializer'

module Spree
  module Hub
    class ResponderSerializer < ActiveModel::Serializer
      attributes :request_id, :summary, :backtrace

      def filter(keys)
        keys.delete(:backtrace) unless object.backtrace.present?
        keys
      end
    end
  end
end
