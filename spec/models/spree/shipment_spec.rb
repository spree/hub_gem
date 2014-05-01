require 'spec_helper'

module Spree
  describe Shipment do

    let!(:shipment) { create(:shipment) }

    it "pushes serialized JSON after saved" do
      Spree::Hub::Config[:enable_push] = true
      Spree::Hub::Config[:enable_auto_push] = true
      expect(shipment).to receive(:push_to_hub)
      shipment.save!
    end

  end
end
