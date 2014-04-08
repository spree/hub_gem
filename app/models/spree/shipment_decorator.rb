module Spree
  Shipment.class_eval do
    belongs_to :order, :touch => true
  end
end
