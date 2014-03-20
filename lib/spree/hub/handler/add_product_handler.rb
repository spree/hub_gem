require 'open-uri'

module Spree
  module Hub
    module Handler
      class AddProductHandler < Base

        attr_accessor :taxon_ids

        def initialize(message)
          super(message)
          @taxon_ids = []
        end

        def process
          params = @payload[:product]

          children_params = params.delete(:children)

          #posible master images
          images = params.delete(:images)
          product = process_root_product(params)
          process_images(product.master, images)

          # if children_params
          #   process_child_products(product, children_params)
          # end

          if product.valid?
            response "Product #{product.sku} added"
          else
            response "Cannot add the product due to validation errors", 500
          end
        end

        # the Spree::Product and Spree::Variant master
        # it's the top level 'product'
        def process_root_product(params)

          id = params.delete(:id)
          permalink = params.delete(:permalink)
          taxons = params.delete(:taxons)
          shipping_category_name = params.delete(:shipping_category)
          options = params.delete(:options)
          properties = params.delete(:properties)

          process_taxons(taxons)

          params[:slug] = permalink if permalink.present?
          params[:taxon_ids] = Spree::Taxon.where(id: @taxon_ids).leaves.pluck(:id)
          params[:shipping_category_id] = process_shipping_category(shipping_category_name)
          product = Spree::Product.create(params)

          process_option_types(product, options)
          process_properties(product, properties)

          product
        end

        # ['color', 'size']
        def process_option_types(product, options)
          return unless options.present?

          options.each do |option_type_name|
            option_type = Spree::OptionType.where(name: option_type_name).first_or_initialize do |option_type|
              option_type.presentation = option_type_name
              option_type.save!
            end
            product.option_types << option_type unless product.option_types.include?(option_type)
          end
        end

        #{"material" => "cotton", "fit" => "smart fit"}
        def process_properties(product, properties)
          return unless properties.present?
          properties.keys.each do |property_name|
            property = Spree::Property.where(name: property_name).first_or_initialize do |property|
              property.presentation = property_name
              property.save!
            end
            Spree::ProductProperty.where(product: product, property: property).first_or_initialize do |pp|
              pp.value = properties[property_name]
              pp.save!
            end
          end
        end

        def process_shipping_category(shipping_category_name)
          Spree::ShippingCategory.where(name: shipping_category_name).first_or_create.id
        end

        def process_taxons(taxons)
          return unless taxons.present?
          taxons.each do |taxons_path|
            return unless taxons_path.present?
            taxonomy_name = taxons_path.shift
            taxonomy = Spree::Taxonomy.where(name: taxonomy_name).first_or_create
            add_taxon(taxonomy.root, taxons_path)
          end
        end

        # recursive method to add the taxons
        def add_taxon(parent, taxon_names, position = 0)
          return unless taxon_names.present?
          taxon_name = taxon_names.shift
          # first_or_create is broken :(
          taxon = Spree::Taxon.where(name: taxon_name, parent_id: parent.id).first
          if taxon
            parent.children << taxon
          else
            taxon = parent.children.create(name: taxon_name, position: position)
          end
          parent.save
          # store the taxon so we can assign it later
          @taxon_ids << taxon.id
          add_taxon(taxon, taxon_names, position+1)
        end

        def process_images(variant, images)
          return unless images.present?

          images.each do |image_hsh|
            image = variant.images.create
            image.attachment = open(image_hsh["url"])
            image.position = image_hsh["position"]
            image.alt = image_hsh["title"]
            image.save!
          end
        end

      end
    end
  end
end
