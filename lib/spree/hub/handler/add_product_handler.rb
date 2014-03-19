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

          #process_images(product.master, images) if images && product.valid?
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

          params[:slug] = permalink if permalink.present?
          process_taxons(taxons)
          params[:taxon_ids] = Spree::Taxon.where(id: @taxon_ids).leaves.pluck(:id)

          if shipping_category_name
            shipping_category_id = Spree::ShippingCategory.where(name: shipping_category_name).first_or_create.id
            params[:shipping_category_id] = shipping_category_id
          end
          product = Spree::Product.create(params)

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
