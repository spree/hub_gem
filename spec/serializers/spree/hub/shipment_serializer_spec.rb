require "spec_helper"

module Spree
  module Hub
    describe ShipmentSerializer do

      let(:shipment) { create(:shipment) }
      let(:serialized_shipment) { ShipmentSerializer.new(shipment, root: false).to_json }

      
    end
  end
end
