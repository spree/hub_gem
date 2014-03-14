require 'json'
require 'openssl'
require 'httparty'

module Spree
  module Hub
    class Client

      def self.push(payload)

        uri = Spree::Hub::Config[:hub_push_uri]
        store_id = Spree::Hub::Config[:hub_store_id]
        access_token = Spree::Hub::Config[:hub_token]
        use_hmac = Spree::Hub::Config[:use_hmac]
        json_payload = JSON.generate(payload)

        if use_hmac
          timestamp  = Time.now.utc.to_i
          data = "#{json_payload}#{timestamp}"
          sha1 = OpenSSL::Digest.new('sha1')
          access_token = OpenSSL::HMAC.hexdigest(sha1, token, data)
        end

        HTTParty.post(
          uri,
          {
            body: json_payload,
            headers: {
             'X-Hub-Store'        => store_id,
             'X-Hub-Access-Token' => access_token,
             'X-Hub-Timestamp'    => timestamp.to_s
            }
          }
        )
      end
    end
  end
end
