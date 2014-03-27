require 'active_model/serializer'

module Spree
  module Hub
    class ShipmentSerializer < ActiveModel::Serializer
      attributes :id, :tracking, :number, :stock_location, :state
    end
  end
end