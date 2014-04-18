module Spree
  module Hub
    module Handler
      class SetInventoryHandler < Base

        def process
          stock_item_id = @payload[:inventory][:id]
          stock_item = Spree::StockItem.find_by_id(stock_item_id)
          return response("StockItem with id #{stock_item_id} was not found", 500) unless stock_item

          count_on_hand = stock_item.count_on_hand
          stock_item.set_count_on_hand(@payload[:inventory][:quantity])

          return response("Set inventory for StockItem with id #{stock_item_id} from #{count_on_hand} to #{stock_item.reload.count_on_hand}")
        end

      end
    end
  end
end
