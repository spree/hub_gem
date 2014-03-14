require 'active_model/serializer'

module Spree
  module Hub
    class AdjustmentSerializer < ActiveModel::Serializer
      attributes :name, :value

      def name
        object.label
      end

      def value
        object.amount.to_f
      end

    end
  end
end
