class CreateUniqueIndexOnSpreeUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :spree_users, :referral_code, unique: true
  end
end
