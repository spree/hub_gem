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

        let!(:message) { ::Hub::Samples::Order.request }
        let(:handler) { Handler::UpdateOrderHandler.new(message.to_json) }

        context "for existing order" do
          let!(:message) { ::Hub::Samples::Order.request }
          let!(:order) { create(:order_with_line_items, number: message["order"]["id"])}

          it "will update the order" do
            responder = handler.process
            expect(responder.summary).to match /Updated Order with number R.{9}/
            expect(responder.code).to eql 200
          end

        end

        context "with no order present" do

          it "returns a Hub::Responder with 500 status" do
            responder = handler.process
            expect(responder.summary).to match /Order with number R.{9} was not found/
            expect(responder.code).to eql 500
          end

        end
      end

    end
  end
end
