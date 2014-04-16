module Spree
  class HubConfiguration < Preferences::Configuration
    preference :enable_push, :boolean, :default => false
    preference :enable_auto_push, :boolean, :default => false
    preference :hub_store_id, :string
    preference :hub_token, :string
    preference :hub_push_uri, :string, :default => 'https://push.hubapp.io'
    preference :use_hmac, :boolean, :default => false
  end
end
