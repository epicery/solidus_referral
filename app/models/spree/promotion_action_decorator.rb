Spree::PromotionAction.class_eval do
  def perform_at_completion(payload = {})
    raise PerformAtCompletionNotImplemented.new('perform_at_completion should be implemented in a sub-class of PromotionAction')
  rescue PerformAtCompletionNotImplemented => e
    puts e.message
  end

  private

  class PerformAtCompletionNotImplemented < StandardError; end
end