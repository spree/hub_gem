require 'active_model/serializer'

module Spree
  module Hub
    class VariantSerializer < ActiveModel::Serializer

      attributes :id, :parent_id, :name, :sku, :description, :price, :cost_price,
                 :available_on, :permalink, :meta_description, :meta_keywords,
                 :shipping_category, :taxons, :options, :images

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
        object.slug
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

      def images
        image_set = []
        object.images.each do |image|
          image_hsh = {
            url: image.attachment.url(:original),
            position: image.position,
            title: image.alt,
            type: "original",
            dimensions: {
              height: image.attachment_height,
              width: image.attachment_width
            }
          }
          image_set << image_hsh
        end
        image_set
      end

    end
  end
end
