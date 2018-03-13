Spree::PromotionAction.class_eval do
  def perform_at_completion(payload = {})
    raise 'perform_at_completion should be implemented in a sub-class of PromotionAction'
  end
end