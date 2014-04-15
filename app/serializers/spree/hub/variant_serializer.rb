require 'active_model/serializer'

module Spree
  module Hub
    class VariantSerializer < ActiveModel::Serializer

      attributes :id, :sku, :price, :cost_price, :options, :name
      attributes :product, :images

      def price
        object.price.to_f
      end

      def cost_price
        object.cost_price.to_f
      end

      def options
        object.option_values.each_with_object({}) {|ov,h| h[ov.option_type.presentation]= ov.presentation}
      end

      def name
        object.product.name
      end

      def product
        hash = {}
        hash[:created_at] = object.product.created_at.getutc.iso8601
        hash[:updated_at] = object.product.updated_at.getutc.iso8601

        hash[:taxons] = object.product.taxons.map{|t| t.slice(:id, :name, :taxonomy_id)}
        hash
      end

    end
  end
end
