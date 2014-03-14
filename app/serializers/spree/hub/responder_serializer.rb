require 'active_model/serializer'

module Spree
  module Hub
    class ResponderSerializer < ActiveModel::Serializer
      attributes :request_id, :summary
    end
  end
end
