Spree::Variant.after_commit -> { Spree::Hub::VariantSerializer.push_it self }
