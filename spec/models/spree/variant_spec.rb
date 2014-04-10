require 'spec_helper'

module Spree
  describe Variant do

    let!(:variant) { create(:variant) }

    it "pushes serialized JSON after saved" do
      expect(Spree::Hub::VariantSerializer).to receive(:push_it).with(variant)
      variant.save!
    end

  end
end
