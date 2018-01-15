class AddSponsorIdToSpreeUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :sponsor_id, :integer
  end
end
