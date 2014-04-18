require "spec_helper"

module Spree
  module Hub
    describe OrderSerializer do

      let!(:order) {create(:shipped_order)}
      let(:serialized_order) do
        JSON.parse(OrderSerializer.new(order, root: false).to_json)
      end

      context "format" do

        it "uses the order number for id" do
          expect(serialized_order["id"]).to eql order.number
        end

        it "uses status for the state" do
          expect(serialized_order["status"]).to eql order.state
        end

        it "set's the placed_on to completed_at date in ISO format" do
          expect(serialized_order["placed_on"]).to match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
        end

        context "totals" do

          let(:totals) do
            {
              "item"=> 50.0,
              "adjustment"=> 0.0,
              "tax"=> 0.0,
              "shipping"=> 100.0,
              "payment"=> 150.0,
              "order"=> 150.0
            }
          end

          it "has all the amounts for the order" do
            expect(serialized_order["totals"]).to eql totals
          end
        end

        context "adjustments key" do
          it "shipment matches order shipping total value" do
            shipping_hash = serialized_order["adjustments"].select { |a| a["name"] == "shipping" }.first
            expect(shipping_hash["value"]).to eq order.shipment_total.to_f
          end
        end
      end

      context "with hub enabled" do

        before do
          Spree::Hub::Config[:enable_push] = true
          Spree::Hub::Config[:enable_auto_push] = true
        end

        context "when status is 'complete'" do
          it "serializes Order object and pushes it to the hub" do
            expect(HTTParty).to receive(:post)
            described_class.push_it order
          end
        end

      end
    end
  end
end
