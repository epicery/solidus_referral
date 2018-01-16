module Spree
  class Promotion
    module Rules
      class UserIsReferred < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          unless order.user.referrer.present?
            eligibility_errors.add(:base, eligibility_error_message(:user_is_not_referred))
          end

          eligibility_errors.empty?
        end
      end
    end
  end
end