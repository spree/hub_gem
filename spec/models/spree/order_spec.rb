require 'spec_helper'

module Spree
  describe Order do

    let!(:order) { create(:order) }

    context "configured to auto push" do
      before do
        Spree::Hub::Config[:enable_push] = true
        Spree::Hub::Config[:enable_auto_push] = true
      end

      it "pushes serialized JSON after saved" do
        expect(order).to receive(:push_to_hub)
        order.save!
      end
    end

    context "when not configured to auto push" do
      before do
        Spree::Hub::Config[:enable_push] = true
        Spree::Hub::Config[:enable_auto_push] = false
      end

      it "will not pushes serialized JSON after saved" do
        expect(order).to_not receive(:push_to_hub)
        order.save!
      end

    end


  end
end
