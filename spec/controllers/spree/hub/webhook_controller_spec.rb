require 'spec_helper'

module Spree
  describe Hub::WebhookController do

    let!(:message) {
      ::Hub::Samples::Order.request
    }

    context '#consume' do
      context 'with unauthorized request' do
        it 'returns 401 status' do
          spree_xhr_post 'consume', {}
          expect(response.code).to eql "401"
        end
      end

      context 'with the correct auth' do
        before do
          request.env['HTTP_X_HUB_STORE'] = '234254as3423r3243'
          request.env['HTTP_X_HUB_TOKEN'] = 'abc1233'
        end

        context 'and an existing handler for the webhook' do
          it 'will process the webhook handler' do
            post 'consume', ::Hub::Samples::Order.request.to_json, {use_route: :spree, format: :json, path: 'add_order'}
            expect(response).to be_success
          end
        end

        context 'when an exception happens' do
          it 'will return resonse with the exception message and backtrace' do
            post 'consume', ::Hub::Samples::Order.request.to_json, {use_route: :spree, format: :json, path: 'update_order'}
            expect(response.code).to eql "500"
            json = JSON.parse(response.body)
            expect(json["summary"]).to eql "uninitialized constant Spree::Hub::Handler::UpdateOrderHandler"
            expect(json["backtrace"]).to be_present
          end
        end

      end
    end
  end
end
