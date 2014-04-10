module Spree
  module Hub
    module Handler
      class UpdateOrderHandler < OrderHandler

        def process
          current_order = Spree::Order.where(number: @payload[:order][:id]).first
          binding.pry

          response "Order with number #{@payload[:order][:id]} was not found", 500 unless current_order
        end

      end
    end
  end
end
