require 'spec_helper'

module Spree
  module Hub
    describe Handler::UpdateProductHandler do
      context "#process" do
        let!(:message) do
          hsh = ::Hub::Samples::Product.request
          hsh["product"]["permalink"] = "other-permalink-then-name"
          hsh["product"].delete "images"
          #hsh["product"].delete "variants"
          hsh
        end

        let!(:variant) { create(:master_variant, sku: message["product"]["sku"])}

        let(:handler) { Handler::UpdateProductHandler.new(message.to_json) }

        it "updates a product in the storefront" do
          expect {
            handler.process
          }.not_to change{ Spree::Product.count }
        end

        it "updates existing variant in the storefront" do
          expect {
            handler.process
          }.not_to change { Spree::Variant.count }
        end

        context "and with a permalink" do
          before do
            handler.process
          end

          it "updates store the permalink as the slug" do
            expect(Spree::Product.where(slug: message["product"]["permalink"]).count).to eql 1
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

          it "returns a summary with the updated product and variant id's" do
            expect(responder.summary).to match "updated"
          end
        end
      end
    end
  end
end
