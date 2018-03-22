module Spree
  class Promotion
    module Rules
      class NotTheSponsorshipOrder < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          if is_first_order?(order) && is_user_referred?(order)
            eligibility_errors.add(:base, eligibility_error_message(:order_is_the_sponsorship_order))
          end

          eligibility_errors.empty?
        end

        private

        def is_first_order?(order)
          Spree::Promotion::Rules::FirstOrder.new.eligible?(order)
        end

        def is_user_referred?(order)
          Spree::Promotion::Rules::UserIsReferred.new.eligible?(order)
        end
      end
    end
  end
end
