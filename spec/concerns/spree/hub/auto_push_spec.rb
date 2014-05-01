require 'spec_helper'
#require 'active_model/serializer'

module Spree
  describe Hub::AutoPush do

    before do
      Spree::Order.send(:include, Spree::Hub::AutoPush)
    end

    it "adds #hub_serializer" do
      expect(Spree::Order.respond_to?(:hub_serializer)).to be true
    end

    it "adds #json_root_name" do
      expect(Spree::Order.respond_to?(:json_root_name)).to be true
    end

    it "adds an 'push_to_hub' after_commit callback" do
      expect(Spree::Order._commit_callbacks.select {|cb| cb.kind.eql?(:after)}.collect(&:filter)).to match_array [:push_to_hub]
    end

    context ".serialized_payload" do
      before do
        Spree::Order.hub_serializer = "CustomSerializer"
        Spree::Order.json_root_name = "pirates"

        Spree::Order.any_instance.stub(:id).and_return 99
        Spree::Order.any_instance.stub(:name).and_return "Pirates on the wall"
      end

      it "serializes with the provided hub_serializer name" do
        json = Spree::Order.new.serialized_payload
        expect(json).to eql "{\"pirates\":[{\"name\":\"99 : Pirates on the wall\"}]}"
      end

    end


  end
end
