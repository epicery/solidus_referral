module Spree
  class Promotion
    module Rules
      class UserIsReferred < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::User)
        end

        def eligible?(user, _options = {})
          unless user.referrer.present?
            eligibility_errors.add(:base, eligibility_error_message(:user_is_not_referred))
          end

          eligibility_errors.empty?
        end
      end
    end
  end
end