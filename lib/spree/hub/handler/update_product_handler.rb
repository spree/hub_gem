module Spree
  module Hub
    module Handler
      class UpdateProductHandler < Base
        attr_reader :params, :options, :taxon_ids, :parent_id

        def initialize(message)
          super message

          @params = @payload[:product]
          @parent_id = params[:parent_id]
          @taxon_ids = []

          params.delete :options
          params.delete :properties
          params.delete :images
          params.delete :parent_id

          params[:slug] = params.delete :permalink if params[:permalink].present?

          # FIXME Getting errors like this for nested taxons:
          #
          #   NoMethodError:
          #   undefined method `touch' for nil:NilClass
          #   .../spree-fa1cb8c1d3a8/core/app/models/spree/taxon.rb:87:in `touch_ancestors_and_taxonomy'
          #
          params.delete :taxons
        end

        def process
          params.delete :channel
          params.delete :id

          set_up_shipping_category

          unless master = Variant.find_by(sku: params[:sku], is_master: true)
            response("Could not find product wih sku #{paramas[:sku]}", 500) and return
          end

          @product = Core::Importer::Product.new(master.product, params).update

          if @product.errors.empty?
            response "Product #{@product.id} updated"
          else
            response "Could not update the Product #{@product.errors.messages.inspect}", 500
          end
        end

        private
          def set_up_shipping_category
            if shipping_category
              id = ShippingCategory.find_or_create_by(name: shipping_category).id
              params[:shipping_category_id] = id
            end
          end

          def shipping_category
            @shipping_category ||= params.delete(:shipping_category) || parameters["spree_shipping_category"]
          end
      end
    end
  end
end
