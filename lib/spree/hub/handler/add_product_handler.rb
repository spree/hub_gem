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
          parent_id = params[:parent_id]
          if parent_id
            master_variant = Spree::Variant.where(id: parent_id).first
            return response "parent product with id #{parent_id} not found!", 500 unless master_variant
          else
            params.delete(:options) # make sure to remove any options in the params here.
            images = params.delete(:images)
            product = add_product(params)
            if product.save
              process_images(product.master, images) if images
              return response "Product '#{product.name}' added with master id: #{product.master.id}"
            else
              return response "could not save product due to validation errors", 500
            end
          end
        end

        # no parent_id, so adding new product and master variant
        def add_product(params)

          id = params.delete(:id)
          permalink = params.delete(:permalink)
          taxons = params.delete(:taxons)
          shipping_category_name = params.delete(:shipping_category)

          params.delete(:parent_id)
          params[:slug] = permalink if permalink.present?

          # taxons are stored as breadcrumbs in an nested array.
          # [["Categories", "Clothes", "T-Shirts"], ["Brands", "Spree"], ["Brands", "Open Source"]]
          if taxons
            taxons.each do |taxons_path|
              taxonomy_name = taxons_path.shift
              taxonomy = Spree::Taxonomy.where(name: taxonomy_name).first_or_create
              add_taxon(taxonomy.root, taxons_path)
            end
            params[:taxon_ids] = Spree::Taxon.where(id: @taxon_ids).leaves.pluck(:id)
          end

          if shipping_category_name
            shipping_category_id = Spree::ShippingCategory.where(name: shipping_category_name).first_or_create.id
            params[:shipping_category_id] = shipping_category_id
          end

          product = Spree::Product.new(params)
          # make sure to set the master variant id to the provided id for
          # future lookups.
          product.master.update_attribute(:id, id)

          # return the new product, it will be saved in the calling method
          product
        end

        # recursive method to add the taxons
        def add_taxon(parent, taxon_names, position = 0)
          return parent if taxon_names.empty?

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
          taxon_ids << taxon.id
          add_taxon(taxon, taxon_names, position+1)
        end

        def process_images(variant, images)
          images.each do |image_hsh|
            image = variant.images.create
            image.attachment = open(image_hsh["url"])
            image.position = image_hsh["position"]
            image.alt = image_hsh["title"]
            image.save!
          end
        end

        # option types is a key value hash with {option_type_name => option_type_value}
        # {"color"=>"GREY", "size"=>"S"}
        def process_options(variant, options)
          product = variant.product
          option_types = []
          option_values = []

          options.each do |name, value|
            option_type = Spree::OptionType.where(name: name).first_or_initialize do |option_type|
              option_type.presentation = name
              option_type.save!
            end

            option_type.option_values.where(name: value).first_or_initialize do |option_value|
              option_value.presentation = value
              option_value.save!
              option_values << option_value
            end

            option_types << option_type
          end

          option_types.each do |option_type|
            product.option_types << option_type unless product.option_types.include?(option_type)
          end

          option_values.each do |option_value|
            variant.option_values << option_value unless variant.option_values.include?(option_value)
          end
        end


      end
    end
  end
end
