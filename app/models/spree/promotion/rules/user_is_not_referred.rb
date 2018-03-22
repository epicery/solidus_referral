module Spree
  class Promotion
    module Rules
      class UserIsNotReferred < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          unless order.user.referrer.nil?
            eligibility_errors.add(:base, eligibility_error_message(:user_is_referred))
          end

          eligibility_errors.empty?
        end
      end
    end
  end
end
