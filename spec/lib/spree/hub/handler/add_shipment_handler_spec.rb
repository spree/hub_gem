require 'spec_helper'

module Spree
  module Hub
    describe Handler::AddShipmentHandler do
      let(:message) {::Hub::Samples::Shipment.request}
      let(:handler) { Handler::AddShipmentHandler.new(message.to_json) }

      describe "process" do

        context "with order present" do
          let!(:order) { create(:order_with_line_items, number: message["shipment"]["order_id"]) }
          let!(:stock_location) { create(:stock_location, name: 'default')}
          let!(:shipping_method) { create(:shipping_method, name: 'UPS Ground (USD)')}
          let!(:variant) { create(:variant, :sku => 'SPREE-T-SHIRT') }
          let!(:country) { create(:country) }
          let!(:state) { create(:state, :country => country, name: "California", abbr: "CA") }

          it "works" do
            handler.process
          end

        end

      end

    end
  end
end
