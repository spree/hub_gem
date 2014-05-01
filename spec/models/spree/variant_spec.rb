require 'spec_helper'

module Spree
  describe Variant do

    let!(:variant) { create(:variant) }

    it "pushes serialized JSON after saved" do
      Spree::Hub::Config[:enable_push] = true
      Spree::Hub::Config[:enable_auto_push] = true
      expect(variant).to receive(:push_to_hub)
      variant.save!
    end

  end
end
