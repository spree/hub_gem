require 'active_model/serializer'

module Spree
  module Hub
    class OrderSerializer < ActiveModel::Serializer

      attributes :id, :status, :channel, :email, :currency, :placed_on, :totals

      has_many :line_items,  serializer: LineItemSerializer
      has_many :adjustments, serializer: AdjustmentSerializer
      has_many :shipments, serializer: ShipmentSerializer
      # has_many :payments
      #
      has_one :shipping_address, serializer: AddressSerializer
      has_one :billing_address, serializer: AddressSerializer

      def id
        object.number
      end

      def status
        object.state
      end

      def placed_on
        object.completed? ? object.completed_at.iso8601 : nil
      end

      def totals
        {
          item: object.item_total.to_f,
          adjustment: object.adjustment_total.to_f,
          tax: object.tax_total.to_f,
          shipping: object.ship_total.to_f,
          payment: object.payments.completed.sum(:amount).to_f,
          order: object.total.to_f
        }
      end

    end
  end
end
