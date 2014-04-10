Spree::Shipment.after_commit -> { Spree::Hub::ShipmentSerializer.push_it(self) if Spree::Hub::Config[:enable_hub] }
