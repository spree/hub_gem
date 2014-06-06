require 'active_model/serializer'

module Spree
  module Hub
    class ShippingSerializer < ActiveModel::Serializer
      attributes :number, :cost, :status, :shipping_method,
                 :tracking, :updated_at, :shipped_at

      def status
        object.state
      end

      def shipping_method
        object.shipping_method.name
      end
    end
  end
end
