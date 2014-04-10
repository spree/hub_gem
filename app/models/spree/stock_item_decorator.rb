Spree::StockItem.after_commit -> { Spree::Hub::StockItemSerializer.push_it(self) unless Spree::Hub::Config[:enable_hub] }
