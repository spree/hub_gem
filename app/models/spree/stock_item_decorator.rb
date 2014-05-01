Spree::StockItem.send(:include, Spree::Hub::AutoPush)
Spree::StockItem.hub_serializer = "Spree::Hub::StockItemSerializer"
Spree::StockItem.json_root_name = 'inventory'
