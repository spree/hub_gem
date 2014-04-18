require 'spree/core'

module Spree
  module Hub
  end
end

require 'spree/hub/client'
require 'spree/hub/engine'
require 'spree/hub/responder'

require 'spree/hub/handler/base'
require 'spree/hub/handler/set_inventory_handler'
require 'spree/hub/handler/add_shipment_handler'
