class ChangeUsersDefaults < ActiveRecord::Migration
  def change
    change_column_default :users, :seeds, 0
    change_column_default :users, :coins, 0
  end
end
