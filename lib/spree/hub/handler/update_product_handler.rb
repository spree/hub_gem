require 'open-uri'

module Spree
  module Hub
    module Handler
      class UpdateProductHandler < ProductHandlerBase

        def process

          if @missing_taxon_ids.present?
            return response "Could not find Taxon with id's #{@missing_taxon_ids}, please make sure the taxon exists", 500
          end

          product = Spree::Product.find_by_id(@params[:id])
          return response "Cannot find product with ID #{params[:id]}!", 500

          # Disable the after_touch callback on taxons
          Spree::Product.skip_callback(:touch, :after, :touch_taxons)

          Spree::Product.transaction do
            @product = process_root_product(product, root_product_attrs)
            process_images(@product.master, @master_images)
            process_child_products(@product, children_params) if @children_params
          end

          if @product.valid?
            # set it again, and touch the product
            Spree::Product.set_callback(:touch, :after, :touch_taxons)
            @product.touch

            if @product.variants.count > 0
              response "Product #{@product.sku} updated, with child skus: #{@product.variants.pluck(:sku)}"
            else
              response "Product #{@product.sku} updated"
            end
          else
            response "Cannot update the product due to validation errors", 500
          end

        end

        # the Spree::Product and Spree::Variant master
        # it's the top level 'product'
        def process_root_product(product, params)
          product.update_attributes(params)
          process_option_types(product, @root_options)
          process_properties(product, @properties)

          product
        end

        # adding variants to the product based on the children hash
        def process_child_products(product, children)
          return unless children.present?

          children.each do |child_product|

            # used for possible assembly feature.
            quantity = child_product.delete(:quantity)

            option_type_values = child_product.delete(:options)

            child_product[:options] = option_type_values.collect {|k,v| {name: k, value: v} }

            images = child_product.delete(:images)

            product.variants.find(child_product['id'].to_i).update_attributes(child_product)

            variant = product.variants.find_by_sku(child_product[:sku])
            if variant
              variant.update_attributes(child_product)
            else
              variant = product.variants.create({ product: product }.merge(child_product))
            end
            process_images(variant, images)
          end

        end

      end
    end
  end
end
