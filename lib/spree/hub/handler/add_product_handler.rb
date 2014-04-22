module Spree
  module Hub
    module Handler
      class AddProductHandler < Base
        attr_reader :params, :options, :taxon_ids, :parent_id

        def initialize(message)
          super message

          @params = @payload[:product]
          @parent_id = params[:parent_id]
          @taxon_ids = []

          params.delete :options
          params.delete :properties
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

          @product = Core::Importer::Product.new(nil, params).create

          if @product.persisted?
            response "Product (#{@product.id}) and master variant (#{@product.master.id}) created"
          else
            response "Could not save the Product #{@product.errors.messages.inspect}", 500
          end
        end

        private
          def set_up_shipping_category
            id = ShippingCategory.find_or_create_by(name: shipping_category).id
            params[:shipping_category_id] = id
          end

          def shipping_category
            params.delete(:shipping_category) || parameters["spree_shipping_category"] || "Default"
          end
      end
    end
  end
end
