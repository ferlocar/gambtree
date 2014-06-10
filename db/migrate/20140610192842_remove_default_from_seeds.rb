class RemoveDefaultFromSeeds < ActiveRecord::Migration
  def change
    change_column_default(:users, :seeds, nil)
  end
end