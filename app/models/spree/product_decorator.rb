Spree::Product.send(:include, Spree::Hub::AutoPush)
Spree::Product.hub_serializer = "Spree::Hub::ProductSerializer"
Spree::Product.json_root_name = 'products'
