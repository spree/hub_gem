Spree::StockItem.after_commit -> { Spree::Hub::StockItemSerializer.push_it self }
