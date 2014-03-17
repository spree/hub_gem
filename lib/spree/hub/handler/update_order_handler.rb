module Spree
  module Hub
    module Handler
      class UpdateOrderHandler < OrderHandler

        def process
          order_number = @payload[:order][:id]
          current_order = Spree::Order.lock(true).find_by(number: order_number)
          if current_order
            response "Updated order with number #{@payload[:order][:id]}", 200
          else
            response "Order with number #{order_number} was not found", 500
          end
        end

      end
    end
  end
end
