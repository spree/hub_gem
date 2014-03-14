require 'spec_helper'

module Spree

  describe Hub::WebhookController do
    context "#consume" do
      context "with unauthorized request" do
        it "returns 401 status" do
          spree_xhr_post 'consume', {}
          expect(response.code).to eql "401"
        end
      end

      context "with the correct auth" do
        before do
          request.env["HTTP_X_HUB-STORE"] = "234254as3423r3243"
          request.env["HTTP_X_HUB-TOKEN"] = "abc1233"
        end

        context "and an existing handler for the webhook" do

          let!(:country) { create(:country) }
          let!(:state) { country.states.first || create(:state, :country => country) }

          let!(:user) do
            user = Spree.user_class.new(:email => "spree@example.com")
            user.generate_spree_api_key!
            user
          end

          let!(:variant) { create(:variant, :id => 73) }
          let!(:payment_method) { create(:credit_card_payment_method) }

          let!(:message) {
            ::Hub::Samples::Order.request.to_json
          }

          let(:body) {
            {
              path: 'add_order',
              webhook: message
            }
          }

          # TODO make proper integration specs from this.
          #  and use maybe stubs here or remove totally.
          it "will process the webhook handler" do
            spree_xhr_post 'consume', body
            expect(response).to be_success
          end
        end
      end
    end
  end
end
