Spree::Order.after_commit -> { Spree::Hub::OrderSerializer.push_it(self) if Spree::Hub::Config[:enable_auto_push] }
