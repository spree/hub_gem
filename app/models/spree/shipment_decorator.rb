module Spree
  Shipment.class_eval do
    belongs_to :order, :touch => true

    attr_accessible :order_id, :cost, :shipped_at, :state,
      :inventory_units_attributes, :address_attributes

  end
end

Spree::Shipment.send(:include, Spree::Hub::AutoPush)
Spree::Shipment.hub_serializer = "Spree::Hub::ShipmentSerializer"
Spree::Shipment.json_root_name = 'shipments'
