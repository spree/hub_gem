Spree::StockItem.after_commit -> { Spree::Hub::StockItemSerializer.push_it(self) if Spree::Hub::Config[:enable_auto_push] }
