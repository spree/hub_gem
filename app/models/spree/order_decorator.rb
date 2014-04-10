Spree::Order.after_commit -> { Spree::Hub::OrderSerializer.push_it(self) unless Spree::Hub::Config[:enable_hub] }
