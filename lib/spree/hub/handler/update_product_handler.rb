module Spree
  module Hub
    module Handler
      class UpdateProductHandler < Base
        def process
          product_params = @payload[:product]
          product_params.delete :channel
          product_params.delete :id
          product_params[:shipping_category_id] = 1

          options = { variants_attrs: variants_params, options_attrs: option_types_params }

          product = Spree::Variant.find_by(sku: product_params[:sku], is_master: true).product
          @product = Core::Importer::Product.new(product, product_params, options).update

          if @product.persisted?
            response "All good!"
          else
            response @product.errors.messages.inspect, 500
          end
        end

        private
          def variants_params
            @payload[:product].fetch(:variants, [])
          end

          def option_types_params
            @payload[:product].fetch(:option_types, [])
          end
      end
    end
  end
end
