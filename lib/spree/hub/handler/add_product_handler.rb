module Spree
  module Hub
    module Handler
      class AddProductHandler < Base

        def process
          params = @payload[:product]

          id = params.delete(:id)
          parent_id = params.delete(:parent_id)
          permalink = params.delete(:permalink)
          taxons = params.delete(:taxons)
          option_types_params = params.delete(:options)
          images = params.delete(:images)

          params[:slug] = permalink if permalink.present?

          if shipping_category_name = params.delete(:shipping_category)
            shipping_category_id = Spree::ShippingCategory.where(name: shipping_category_name).first_or_create.id
            params[:shipping_category_id] = shipping_category_id
          end

          if parent_id
            product = Spree::Product.where(id: parent_id).first
            if product
              product.variants.create({ product: product }.merge(params))
            else
              return response "parent product with id #{parent_id} not found!", 500
            end
          else
            product = Spree::Product.new(params)
          end

          if product.save
            master_variant = product.master
            response "Product (#{product.id}) and master variant (#{master_variant.id}) are added"
          else
            response "Could not save the Variant #{product.errors}", 500
          end

        end

      end
    end
  end
end
