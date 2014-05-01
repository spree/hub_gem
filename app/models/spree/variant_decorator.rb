Spree::Variant.send(:include, Spree::Hub::AutoPush)
Spree::Variant.hub_serializer = "Spree::Hub::VariantSerializer"
Spree::Variant.json_root_name = 'products'
