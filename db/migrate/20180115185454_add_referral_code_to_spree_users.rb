class AddReferralCodeToSpreeUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :referral_code, :string
  end
end
