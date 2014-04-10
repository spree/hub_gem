require 'spec_helper'

module Spree
  describe Shipment do

    let!(:shipment) { create(:shipment) }

    it "pushes serialized JSON after saved" do
      expect(Spree::Hub::ShipmentSerializer).to receive(:push_it).with(shipment)
      shipment.save!
    end

  end
end
