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


        def process
          params = @payload[:product]

          id = params.delete(:id)
          parent_id = params.delete(:parent_id)
          permalink = params.delete(:permalink)
          taxons = params.delete(:taxons)
          option_types_params = params.delete(:options)
          images = params.delete(:images)
          shipping_category_name = params.delete(:shipping_category)

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

          # option types is a key value hash with {option_type_name => option_type_value}
          # {"color"=>"GREY", "size"=>"S"}
          option_types = []
          if option_types_params
            option_types_params.each do |name, value|
              option_type = Spree::OptionType.where(name: name).first_or_initialize do |option_type|
                option_type.presentation = name
                option_type.save!
              end
              # TODO for 'variants'
              # option_type.option_values.where(name: value).first_or_initialize do |option_value|
              #   option_value.presentation = value
              #   option_value.save!
              # end
              option_types << option_type
            end
          end

          if shipping_category_name
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
            option_types.each do |option_type|
              product.option_types << option_type unless product.option_types.include?(option_type)
            end
            # TODO make sure we make this work for variants not master
            if images
              images.each do |image_hsh|
                image = product.images.create
                image.attachment = open(image_hsh["url"])
                image.position = image_hsh["position"]
                image.alt = image_hsh["title"]
                image.save!
              end
            end

            response "Product (#{product.id}) and master variant (#{master_variant.id}) are added"
          else
            response "Could not save the Variant #{product.errors}", 500
          end

        end

      end
    end
  end
end
