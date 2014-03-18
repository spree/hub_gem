require "spec_helper"

module Spree
  module Hub
    describe VariantSerializer do

      let(:variant) { create(:variant) }
      let(:serialized_variant) { JSON.parse( VariantSerializer.new(variant, root: false).to_json) }

      context "format" do

        it "serializes the price as float" do
          expect(serialized_variant["price"].class).to eql Float
        end

        it "serializes the cost price as float" do
          expect(serialized_variant["cost_price"].class).to eql Float
        end

        it "serializes the available_on in ISO format" do
          expect(serialized_variant["available_on"]).to match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
        end

        it "serializes the slug as permalink" do
          expect(serialized_variant["permalink"]).to eql variant.slug
        end

        it "serializes the shipping category name as shipping_category" do
          expect(serialized_variant["shipping_category"]).to eql variant.shipping_category.name
        end

        context "without taxons" do
          it "returns [] for 'taxons'" do
            expect(serialized_variant["taxons"]).to eql []
          end
        end

        context "taxons" do
          let(:taxon)    { create(:taxon, name: 't-shirts', :parent => create(:taxon, name: 'Categories')) }
          let(:taxon2)   { create(:taxon, name: 'modern') }
          let(:product)  { variant.product }

          before do
            product.stub :taxons => [taxon, taxon2]
          end

          it "serailizes the taxons as nested arrays" do
            expect(serialized_variant["taxons"]).to eql [["Categories", "t-shirts"], ["modern"]]
          end

        end

        context "without options" do

          let(:variant) { create(:product).master }

          it "returns {} for 'options'" do
            expect(serialized_variant["options"].class).to eql Hash
            expect(serialized_variant["options"]).to be_empty
          end

        end

        context "options" do
          it "returns a hash with 'option_type => value'" do
            options_hash = {"Size" => "S"}
            expect(serialized_variant["options"]).to eql options_hash
          end
        end

        context "for 'variant'" do
          it "serializes the 'master' id as parent_id" do
            expect(serialized_variant["parent_id"]).to eql variant.product.master.id
          end
        end

        context "for master product" do
          let(:variant) { create(:master_variant) }
          it "serializes the parent_id as nil" do
            expect(serialized_variant["parent_id"]).to eql nil
          end
        end

        context "without images" do
          it "returns [] for 'images'" do
            expect(serialized_variant["images"]).to eql []
          end
        end

        context "images" do
          it "serialized the original images for the variant" do
            pending
          end
        end

      end

    end
  end
end
