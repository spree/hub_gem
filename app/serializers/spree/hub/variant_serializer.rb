require 'active_model/serializer'

module Spree
  module Hub
    class VariantSerializer < ActiveModel::Serializer

      attributes :id, :parent_id, :name, :sku, :description, :price, :cost_price,
                  :available_on, :permalink, :meta_description, :meta_keywords,
                  :taxons, :options, :images

      has_many :images, serializer: Spree::Hub::ImageSerializer

      def parent_id
        object.is_master? ? nil : object.product.master.id
      end

      def price
        object.price.to_f
      end

      def cost_price
        object.cost_price.to_f
      end

      def available_on
        object.available_on.iso8601
      end

      def permalink
        object.permalink
      end

      def shipping_category
        object.shipping_category.name
      end

      def taxons
        object.product.taxons.collect {|t| t.root.self_and_descendants.collect(&:name)}
      end

      def options
        object.option_values.each_with_object({}) {|ov,h| h[ov.option_type.presentation]= ov.presentation}
      end

    end
  end
end
