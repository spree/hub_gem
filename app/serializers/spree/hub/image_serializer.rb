require 'active_model/serializer'

module Spree
  module Hub
    class ImageSerializer < ActiveModel::Serializer
      attributes :url, :position, :title, :type, :dimensions

      def url
        add_host_prefix(object.attachment.url(:original))
      end

      def title
        object.alt
      end

      def type
        "original"
      end

      def dimensions
        {
          height: object.attachment_height,
          width: object.attachment_width
        }
      end

      private

      def add_host_prefix(url)
        URI.join(ActionController::Base.asset_host, url).to_s
      end

    end
  end
end
