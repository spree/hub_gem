require 'active_model/serializer'

module Spree
  module Hub
    class LineItemSerializer < ActiveModel::Serializer
      attributes :id, :product_id, :name, :quantity, :price, :created_at, :updated_at

      has_one :variant, serializer: Spree::Hub::VariantSerializer

      def product_id
        object.variant.sku
      end

      def price
        object.price.to_f
      end

      def created_at
        object.created_at.getutc.iso8601
      end

      def updated_at
        object.updated_at.getutc.iso8601
      end

    end
  end
end
