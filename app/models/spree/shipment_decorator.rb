module Spree
  Shipment.class_eval do
    belongs_to :order, :touch => true
  end
end

Spree::Shipment.send(:include, Spree::Hub::AutoPush)
Spree::Shipment.hub_serializer = "Spree::Hub::ShipmentSerializer"
Spree::Shipment.json_root_name = 'shipments'
