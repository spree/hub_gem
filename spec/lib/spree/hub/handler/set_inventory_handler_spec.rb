require 'spec_helper'

module Spree
  module Hub
    describe Handler::SetInventoryHandler do

      let(:message) {::Hub::Samples::Inventory.request}
      let(:handler) { Handler::SetInventoryHandler.new(message.to_json) }

      describe "process" do

        context "with stock item present" do
          let!(:variant) { create(:variant, :sku => 'SPREE-T-SHIRT') }

          it "will set the inventory to the supplied amount" do
            expect{handler.process}.to change{variant.reload.count_on_hand}.from(5).to(93)
          end

        end

      end

    end
  end
end
