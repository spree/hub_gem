require 'spec_helper'

module Spree
  describe Product do

    let!(:product) { create(:product) }

    it "pushes serialized JSON after saved" do
      Spree::Hub::Config[:enable_push] = true
      Spree::Hub::Config[:enable_auto_push] = true
      expect(product).to receive(:push_to_hub)
      product.save!
    end

  end
end
