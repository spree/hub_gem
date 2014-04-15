module Spree
  module Hub
    class WebhookController < ActionController::Base
      before_filter :save_request_data, :authorize
      rescue_from Exception, :with => :exception_handler

      def consume
        handler = Handler::Base.build_handler(@called_hook, @webhook_body)
        responder = handler.process
        
        Rails.logger.warn(responder) && Rails.logger.warn(handler) if responder.nil?

        render json: responder, root: false, status: responder.code
      end

      protected
      def authorize
        unless request.headers['HTTP_X_HUB_STORE'] == Spree::Hub::Config[:hub_store_id] && request.headers['HTTP_X_HUB_TOKEN'] == Spree::Hub::Config[:hub_token]
          base_handler = Handler::Base.new(@webhook_body)
          responder = base_handler.response('Unauthorized!', 401)
          render json: responder, root: false, status: responder.code
          return false
        end
      end

      def exception_handler(exception)
        base_handler = Handler::Base.new(@webhook_body)
        responder = base_handler.response(exception.message, 500)
        responder.backtrace = exception.backtrace.to_s
        render json: responder, root: false, status: responder.code
        return false
      end

      def save_request_data
        @called_hook = params[:path]
        @webhook_body = request.body.read
      end
      
    end
  end
end
