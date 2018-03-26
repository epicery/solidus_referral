Spree::User.class_eval do
  belongs_to :referrer, class_name: 'Spree::User', foreign_key: :referrer_id
  has_many :referred_users, class_name: 'Spree::User', foreign_key: :referrer_id

  before_create :ensure_user_has_referral_code

  def ensure_user_has_referral_code
    self.referral_code ||= generate_referral_code
  end

  private

  def generate_referral_code
    prefix    = 'REF'
    length    = 6
    possible  = (0..9).to_a

    loop do
      # Make a random number.
      random = "#{prefix}#{(0...length).map { possible.sample }.join}"
      # Use the random number if no other order exists with it.
      if Spree::User.exists?(referral_code: random)
        # If over half of all possible options are taken add another digit.
        length += 1 if Spree::User.count > (10**length / 2)
      else
        break random
      end
    end
  end
end
