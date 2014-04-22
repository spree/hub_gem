require 'spec_helper'

module Spree
  module Hub
    describe Handler::SetInventoryHandler do
      let(:message) {::Hub::Samples::Inventory.request}
      let(:handler) { Handler::SetInventoryHandler.new(message.to_json) }

      describe "process" do

        context "with stock item present" do
          let!(:variant) { create(:variant, :sku => 'SPREE-T-SHIRT') }
          let!(:stock_item) { variant.stock_items.first }

          before do
            Spree::StockItem.stub(:find_by_id).and_return(stock_item)
          end

          it "will set the inventory to the supplied amount" do
            expect{handler.process}.to change{stock_item.count_on_hand}.from(0).to(93)
          end

          it "returns a Hub::Responder with a proper message" do
            responder = handler.process
            expect(responder.summary).to eql "Set inventory for StockItem with id 12 from 0 to 93"
            expect(responder.code).to eql 200
          end
        end

        context "with stock item not present" do
          it "returns a Hub::Responder with 500 status" do
            responder = handler.process
            expect(responder.summary).to eql "StockItem with id 12 was not found"
            expect(responder.code).to eql 500
          end
        end

      end

    end
  end
end
