Spree::Order.class_eval do
  state_machine.after_transition to: :complete, do: :trigger_perform_at_completion_in_promotion_actions

  private

  def trigger_perform_at_completion_in_promotion_actions
    promotions.select{ |promo| promo.eligible?(self) }.map(&:actions).flatten.each do |action|
      next unless action.respond_to?(:perform_at_completion)
      performed = action.perform_at_completion({ order: self })
    end
  end
end
