require "active_model/serializer_support"

module Spree
  module Hub
    class Responder
      include ActiveModel::SerializerSupport
      attr_accessor :request_id, :summary, :code, :backtrace

      def initialize(request_id, summary, code=200)
        self.request_id = request_id
        self.summary = summary
        self.code = code
      end

    end
  end
end
