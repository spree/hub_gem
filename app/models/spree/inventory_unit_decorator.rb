module Spree
  InventoryUnit.class_eval do
    belongs_to :shipment, :touch => true
  end
end
