Rails.application.config.spree.promotions.rules   << Spree::Promotion::Rules::UserIsReferred
Rails.application.config.spree.promotions.actions << Spree::Promotion::Actions::AddStoreCreditToReferrer