Spree::Order.after_commit -> { Spree::Hub::OrderSerializer.push_it self }
