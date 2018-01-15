Spree::User.class_eval do
  belongs_to :sponsor, class_name: 'Spree::User', foreign_key: :sponsor_id
  has_many :sponsored_users, class_name: 'Spree::User', foreign_key: :sponsor_id
end