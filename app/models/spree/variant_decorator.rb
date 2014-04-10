Spree::Variant.after_commit -> { Spree::Hub::VariantSerializer.push_it(self) if Spree::Hub::Config[:enable_hub] }
