require 'spec_helper'

module Spree
  describe Order do

    let!(:order) { create(:order) }

    it "pushes serialized JSON after saved" do
      expect(Spree::Hub::OrderSerializer).to receive(:push_it).with(order)
      order.save!
    end

  end
end
