require 'spec_helper'

module Spree
  module Hub
    describe Handler::AddProductHandler do

      context "#process" do
        context "with a master product (ie no parent_id)" do

          let!(:message) do
            hsh = ::Hub::Samples::Product.request
            hsh["product"]["parent_id"] = nil
            hsh
          end

          let(:handler) { Handler::AddProductHandler.new(message.to_json) }

          it "imports a new product with variant master in the storefront" do
            expect{handler.process}.to change{Spree::Variant.count}.by(1)
            expect{handler.process}.to change{Spree::Product.count}.by(1)
          end

          it "returns a Hub::Responder" do
            responder = handler.process
            expect(responder.class.name).to eql "Spree::Hub::Responder"
            expect(responder.request_id).to eql message["request_id"]
            expect(responder.code).to eql 200
            expect(responder.summary).to match /Product \(\d\) and master variant \(\d\) are added/
          end
        end
      end

    end
  end
end
