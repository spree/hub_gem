require "spec_helper"

module Spree
  module Hub
    describe OrderSerializer do

      let(:order) {create(:shipped_order)}
      let(:serialized_order) { OrderSerializer.new(order, root: false).to_json }

      context "format" do

        it "uses the order number for id" do
          expect(JSON.parse(serialized_order)["id"]).to eql order.number
        end

        it "uses status for the state" do
          expect(JSON.parse(serialized_order)["status"]).to eql order.state
        end

        it "set's the placed_on to completed_at date in ISO format" do
          expect(JSON.parse(serialized_order)["placed_on"]).to match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
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
            expect(JSON.parse(serialized_order)["totals"]).to eql totals
          end
        end
      end

      context "custom attributes" do
        it "adds the custom attributes" do
          pending
        end
      end

    end
  end
end
