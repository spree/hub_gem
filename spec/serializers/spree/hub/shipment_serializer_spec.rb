require "spec_helper"

module Spree
  module Hub
    describe ShipmentSerializer do

      let(:shipment) { create(:shipment) }
      let(:serialized_shipment) { JSON.parse (ShipmentSerializer.new(shipment, root: false).to_json) }

      it "serializes the number as id" do
        expect(serialized_shipment["id"]).to eql shipment.number
      end

      it "serializes the order number as order_id" do
        expect(serialized_shipment["order_id"]).to eql shipment.order.number
      end

      it "serializes the cost as float" do
        expect(serialized_shipment["cost"].class).to eql Float
      end

      it "serializes the state at status" do
        expect(serialized_shipment["status"]).to eql shipment.state
      end

    end
  end
end
