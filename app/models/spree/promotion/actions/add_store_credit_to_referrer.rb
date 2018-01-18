module Spree
  class Promotion
    module Actions
      class AddStoreCreditToReferrer < Spree::PromotionAction
        preference :amount, :decimal, default: 10.0
        preference :category, :string, default: 'Default'
        preference :type, :string, default: 'Non-expiring'

        def perform(payload = {})
          true
        end

        def perform_at_completion(payload = {})
          order    = payload[:order]
          user     = order.user
          referrer = user.referrer

          referrer.store_credits.create!(
            user: referrer,
            created_by_id: user.id,
            amount: preferred_amount,
            currency: Spree::Config[:currency],
            category: Spree::StoreCreditCategory.find_by(name: preferred_category),
            credit_type: Spree::StoreCreditType.find_by(name: preferred_type)
          )

          true
        end
      end
    end
  end
end