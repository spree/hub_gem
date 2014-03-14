require 'spec_helper'

module Spree
  module Hub
    describe Handler::SetInventoryHandler do
      context "#consume" do
        it "handles the set_inventory webhook" do
          pending "need more info"
          webhook_message = ::Hub::Samples::Inventory.request.to_json
          handler = Handler::SetInventoryHandler.new(webhook_message)
          expect{ handler.process }.to change{Stock}
        end
      end
    end
  end
end
