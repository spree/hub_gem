Spree::Variant.after_commit -> { Spree::Hub::VariantSerializer.push_it(self) unless Spree::Hub::Config[:enable_hub] }
