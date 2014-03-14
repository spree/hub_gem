require 'spec_helper'

module Spree
  module Hub
    describe Handler::UpdateOrderHandler do

      let!(:country) { create(:country) }
      let!(:state) { country.states.first || create(:state, :country => country) }

      let!(:user) do
        user = Spree.user_class.new(:email => "spree@example.com")
        user.generate_spree_api_key!
        user
      end

      let!(:variant) { create(:variant, :id => 73) }
      let!(:payment_method) { create(:credit_card_payment_method) }

      context "#process" do
        context "with no order present" do
          let!(:message) { ::Hub::Samples::Order.request }
          let(:handler) { Handler::UpdateOrderHandler.new(message.to_json) }

          it "returns a Hub::Responder with 500 status" do
            responder = handler.process
            expect(responder.class.name).to eql "Spree::Hub::Responder"
            expect(responder.request_id).to eql message["request_id"]
            expect(responder.summary).to match /Order with number R.{9} was not found/
            expect(responder.code).to eql 500
          end

        end
      end

    end
  end
end
