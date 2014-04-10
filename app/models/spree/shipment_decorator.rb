Spree::Shipment.after_commit -> { Spree::Hub::ShipmentSerializer.push_it self }
