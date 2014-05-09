Spree::Order.send(:include, Spree::Hub::AutoPush)
Spree::Order.hub_serializer = "Spree::Hub::OrderSerializer"
Spree::Order.json_root_name = 'orders'
Spree::Order.push_when = -> order { order.complete? }
