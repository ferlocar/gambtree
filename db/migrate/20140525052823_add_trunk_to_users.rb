class AddTrunkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_trunk, :boolean
  end
end
