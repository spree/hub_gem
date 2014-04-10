module Spree
  module Hub
    module Handler
      class UpdateOrderHandler < OrderHandler

        def process
          find_order(@payload[:order][:id])

          order_params = OrderHandler.order_params(@payload[:order])
          order_params.delete(:number)
          order_params.delete(:id)
          order_params.delete(:totals)

          payments_attr = order_params.delete(:payments_attributes)
          adjustments_attr = order_params.delete(:adjustments_attributes)
          line_items_attr = order_params.delete(:line_items_attributes)
          @order.update_attributes(order_params)

        end

        private
        def find_order(number)
          @order = Spree::Order.lock(true).find_by!(number: number)
        end

      end
    end
  end
end
