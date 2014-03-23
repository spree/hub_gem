require 'active_model/serializer'

module Spree
  module Hub
    # Accepts a Spree::Variant and serializes this to the Hub Product format
    class ProductSerializer < ActiveModel::Serializer

      attributes :id, :parent_id, :name, :sku, :description, :price, :cost_price,
                 :available_on, :permalink, :meta_description, :meta_keywords,
                 :shipping_category, :taxons, :options, :images


      #has_many :images, serializer: ImageSerializer

      def parent_id
        object.product.master.id
      end

      def price
        object.price.to_f
      end

      def cost_price
        object.cost_price.to_f
      end

      def available_on
        object.available_on.try :iso8601
      end

      def permalink
        object.product.permalink
      end

      def shipping_category
        object.shipping_category.name
      end

      def taxons
        object.product.taxons.collect(&:name)
      end

      def options
        object.option_values.each_with_object({}) {|ov,h| h[ov.option_type.presentation]= ov.presentation}
      end

      def images
      end

    end
  end
end
