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
            response "Product (#{product.id}) and master variant (#{master_variant.id}) are added"
          else
            response "Could not save the Variant #{product.errors}", 500
          end

        end

      end
    end
  end
end
