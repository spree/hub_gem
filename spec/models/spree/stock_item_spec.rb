require 'spec_helper'

module Spree
  describe StockItem do

    let!(:variant) { create(:variant) }
    let!(:stock_item) { variant.stock_items.first }

    it "pushes serialized JSON after saved" do
      Spree::Hub::Config[:enable_push] = true
      Spree::Hub::Config[:enable_auto_push] = true
      expect(stock_item).to receive(:push_to_hub)
      stock_item.save!
    end

  end
end
