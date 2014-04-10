Spree::Shipment.after_commit -> { Spree::Hub::ShipmentSerializer.push_it(self) unless Spree::Hub::Config[:enable_hub] }
