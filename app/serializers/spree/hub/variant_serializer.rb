require 'active_model/serializer'

module Spree
  module Hub
    class VariantSerializer < ActiveModel::Serializer

      attributes :sku, :price, :cost_price, :options
      has_many :images, serializer: Spree::Hub::ImageSerializer

      def price
        object.price.to_f
      end

      def cost_price
        object.cost_price.to_f
      end

      def options
        object.option_values.each_with_object({}) {|ov,h| h[ov.option_type.presentation]= ov.presentation}
      end

    end
  end
end
