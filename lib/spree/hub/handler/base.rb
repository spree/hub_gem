require 'json'

module Spree
  module Hub
    module Handler
      class Base

        attr_accessor :payload, :parameters, :request_id

        def initialize(message)
          self.payload = ::JSON.parse(message).with_indifferent_access
          self.request_id = payload.delete(:request_id)

          if payload.key? :parameters
            if payload[:parameters].is_a? Hash
              self.parameters = payload.delete(:parameters).with_indifferent_access
            end
          end
          self.parameters ||= {}
        end

        def self.build_handler(path, message)
          klass = ("Spree::Hub::Handler::" + path.camelize + "Handler").constantize
          klass.new(message)
        end

        def response(message, code = 200)
          Spree::Hub::Responder.new(@request_id, message, code)
        end

        def process
          raise "Please implement the process method in your handler"
        end

      end
    end
  end
end
