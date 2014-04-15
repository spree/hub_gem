require 'spec_helper'

module Spree
  describe Variant do

    let!(:variant) { create(:variant) }

    it "pushes serialized JSON after saved" do
      Spree::Hub::Config[:enable_hub] = true
      expect(Spree::Hub::VariantSerializer).to receive(:push_it).with(variant)
      variant.save!
    end

  end
end
