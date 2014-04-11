module Spree
  module Hub
    module Handler
      class UpdateShipmentHandler < Base
        def process
          current_order = Spree::Order.where(id: @payload[:order][:id]).first

          shipment = current_order.shipments.first
          if shipment.present?
            shipment.tracking = @payload[:order][:tracking]
            shipment.state = "shipped"
            shipment.save
          end
          response "Order with shipments #{@payload[:order][:id]} was not found", 500 unless shipment
        end        
      end      
    end
  end
end
