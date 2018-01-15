Spree::User.class_eval do
  belongs_to :referrer, class_name: 'Spree::User', foreign_key: :referrer_id
  has_many :referred_users, class_name: 'Spree::User', foreign_key: :referrer_id
end