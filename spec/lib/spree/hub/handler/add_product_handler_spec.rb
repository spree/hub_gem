require 'spec_helper'

module Spree
  module Hub
    describe Handler::AddProductHandler do

      let(:message) { ::Hub::Samples::Product.request }
      let(:handler) { Handler::AddProductHandler.new(message.to_json) }

      describe ".process_taxons" do
        # taxons are stored as breadcrumbs in an nested array.
        let(:taxons) {[["Categories", "Clothes", "T-Shirts"], ["Brands", "Spree"], ["Brands", "Open Source"]]}

        context "without taxons" do
          let(:taxons) {[]}

          it "will just return" do
            expect(handler.process_taxons(taxons)).to eql nil
          end

          it "will not add any taxons" do
            expect{handler.process_taxons(taxons)}.to_not change{Spree::Taxon.count}
          end

          it "will not add any taxonomies" do
            expect{handler.process_taxons(taxons)}.to_not change{Spree::Taxonomy.count}
          end

          context "with empty taxon paths" do
            let(:taxons) {[[]]}
            it "will just return" do
              expect(handler.process_taxons(taxons)).to eql nil
            end
            it "will not add any taxons" do
              expect{handler.process_taxons(taxons)}.to_not change{Spree::Taxon.count}
            end

            it "will not add any taxonomies" do
              expect{handler.process_taxons(taxons)}.to_not change{Spree::Taxonomy.count}
            end
          end
        end

        context "with taxons" do
          it "will nest all properly" do
            handler.process_taxons(taxons)

            # [
            #   ["Categories", "Clothes", "T-Shirts"],
            #   ["Brands", "Spree"],
            #   ["Brands", "Open Source"]
            # ]

            categories = Spree::Taxonomy.find_by_name("Categories")
            brands = Spree::Taxonomy.find_by_name("Brands")

            # just "Clothes"
            expect(categories.root.children.count).to eql 1

            # ["Clothes", "T-Shirts"]
            expect(categories.root.descendants.count).to eql 2

            # just "T-Shirts"
            expect(categories.root.leaves.count).to eql 1

            # "Spree" and "Open Source"
            expect(brands.root.children.count).to eql 2

            # "Spree" and "Open Source"
            expect(brands.root.descendants.count).to eql 2

            # "Spree" and "Open Source"
            expect(brands.root.leaves.count).to eql 2

          end

          context "and no taxons present" do
            it "will add the first item for every nested array as taxonomy if not present yet" do
              # Categories & Brands
              expect{handler.process_taxons(taxons)}.to change{Spree::Taxonomy.count}.by(2)
            end

            it "will add the other elements to the taxonomies" do
              # Brands will only be added 1 time.
              expect{handler.process_taxons(taxons)}.to change{Spree::Taxon.count}.by(6)
            end
          end

          context "and a taxonomy already present" do
            let!(:taxonomy) { create(:taxonomy, name: "Brands") }

            it "will only add the not present taxonomies" do
              expect{handler.process_taxons(taxons)}.to change{Spree::Taxonomy.count}.by(1)
            end
            it "will only add the not present taxons" do
              expect{handler.process_taxons(taxons)}.to change{Spree::Taxon.count}.by(5)
            end
          end

        end

      end

      describe ".add_taxon" do

        let!(:taxonomy) { create(:taxonomy) }
        let!(:parent) { taxonomy.root }

        context "with no taxon_names" do
          let(:taxon_names) { [] }
          it "will just return" do
            expect(handler.add_taxon(parent,taxon_names)).to eql nil
          end
          it "will not add any taxons" do
            expect{handler.add_taxon(parent,taxon_names)}.to_not change{Spree::Taxon.count}
          end
        end

        context "with taxon_names" do
          let(:taxon_names) { ["Clothes", "T-Shirts"] }

          it "will save the taxon_ids for assignment later" do
            handler.add_taxon(parent,taxon_names)
            expect(handler.taxon_ids.size).to eql 2
          end

          context "and no existing taxons" do
            it "will add the taxons " do
              expect{handler.add_taxon(parent, taxon_names)}.to change{Spree::Taxon.count}.by(2)
            end

            # parent_taxon > Clothes > T-Shirts
            it "will nest the taxons inside each other" do
              handler.add_taxon(parent, taxon_names)
              expect(parent.children.count).to eql 1
              expect(parent.descendants.count).to eql 2
              expect(parent.leaves.count).to eql 1
            end
          end

          context "with same taxon already existing" do
            before do
              taxonomy.root.children << create(:taxon, name: "Clothes")
            end
            it "will only add missing taxons" do
              expect{handler.add_taxon(parent, taxon_names)}.to change{Spree::Taxon.count}.by(1)
            end
          end

        end

      end

      describe ".process_images" do

        let(:variant) { create(:product).master }
        let(:images) { message["product"]["images"]}

        context "with empty images" do
          let(:images) {[]}
          it "will just return" do
            expect(handler.process_images(variant,images)).to eql nil
          end
          it "will not add any images" do
            expect{handler.process_images(variant,images)}.to_not change{Spree::Image.count}
          end
        end

        context "with images with valid url" do
          before do
            img_fixture = File.open(File.expand_path('../../../../../fixtures/thinking-cat.jpg', __FILE__))
            Handler::AddProductHandler.any_instance.stub(:open).and_return img_fixture
          end

          it "will download the image and assign it" do
            expect{handler.process_images(variant,images)}.to change{Spree::Image.count}.by(1)
          end
        end

        context "with invalid image url" do
          it "will raise an exception" do
            expect{handler.process_images(variant,images)}.to raise_error
          end
        end
      end

      describe ".process_options" do
        pending "in concept"
      end

      describe ".process_properties" do
        pending "in concept"
      end

      describe ".add_product" do
        pending "in concept"
      end


      describe "#process" do

        before do
          img_fixture = File.open(File.expand_path('../../../../../fixtures/thinking-cat.jpg', __FILE__))
          Handler::AddProductHandler.any_instance.stub(:open).and_return img_fixture
        end
        context "with a master variant (ie no parent_id)" do

          let!(:message) do
            hsh = ::Hub::Samples::Product.request
            hsh["product"]["parent_id"] = nil
            hsh["product"]["permalink"] = "other-permalink-then-name"
            hsh
          end

          let(:handler) { Handler::AddProductHandler.new(message.to_json) }

          it "imports a new product in the storefront" do
            expect{handler.process}.to change{Spree::Product.count}.by(1)
          end

          it "imports a new variant master in the storefront" do
            expect{handler.process}.to change{Spree::Variant.count}.by(1)
          end

          context "and with a permalink" do
            before do
              handler.process
            end

            it "will store the permalink as the slug" do
              expect(Spree::Product.where(slug: message["product"]["permalink"]).count).to eql 1
            end
          end

          context "with taxons" do
            it "will assign the taxon leaves to the product" do
              handler.process
              product = Spree::Product.find_by_slug("other-permalink-then-name")
              expect(product.taxons.count).to eql 3
              product.taxons.each do |taxon|
                expect(taxon.leaf?).to be_true
              end
              expect(product.taxons.pluck(:name)).to eql ["T-Shirts", "Spree", "Open Source"]
            end
          end

          context "with images" do
            it "it will download the image at add the attachment" do
              handler.process
              product = Spree::Product.find_by_slug("other-permalink-then-name")
              expect(product.images.count).to be 1
            end
          end

          context "response" do
            let(:responder) { handler.process }

            it "is a Hub::Responder" do
              expect(responder.class.name).to eql "Spree::Hub::Responder"
            end

            it "returns the original request_id" do
              expect(responder.request_id).to eql message["request_id"]
            end

            it "returns http 200" do
              expect(responder.code).to eql 200
            end

            it "returns a summary with the created product and variant id's" do
              product_name = message["product"]["name"]
              product_id = message["product"]["id"]
              expected_summary = "Product '#{product_name}' added with master id: #{product_id}"
              expect(responder.summary).to eql expected_summary
            end
          end

        end
      end

    end
  end
end
