require 'active_model/serializer'

module Spree
  module Hub
    class OrderSerializer < ActiveModel::Serializer

      attributes :id, :status, :channel, :email, :currency, :placed_on, :updated_at, :totals,
        :adjustments, :token

      has_many :line_items,  serializer: Spree::Hub::LineItemSerializer
      has_many :payments, serializer: Spree::Hub::PaymentSerializer

      has_one :shipping_address, serializer: Spree::Hub::AddressSerializer
      has_one :billing_address, serializer: Spree::Hub::AddressSerializer

      def id
        object.number
      end

      def status
        object.state
      end

      def placed_on
        object.completed_at.try(:iso8601)
      end

      def totals
        {
          item: object.item_total.to_f,
          adjustment: object.adjustment_total.to_f,
          tax: tax_total,
          shipping: shipping_total,
          payment: object.payments.completed.sum(:amount).to_f,
          order: object.total.to_f
        }
      end

      def adjustments
        [
          { name: "tax", value: tax_total },
          { name: "shipping", value: shipping_total }
        ]
      end

      private
        def shipping_total
          object.ship_total.to_f
        end

        def tax_total
          object.tax_total.to_f
        end
    end
  end
end
