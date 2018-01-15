class AddReferrerIdToSpreeUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :referrer_id, :integer
  end
end
