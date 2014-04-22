module Spree
  module Hub
    module Handler
      class AddProductHandler < Base
        def process
          product_params = @payload[:product]
          product_params.delete :channel
          product_params.delete :id
          product_params[:shipping_category_id] = 1

          options = { variants_attrs: variants_params, options_attrs: option_types_params }
          @product = Core::Importer::Product.new(nil, product_params, options).create

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
