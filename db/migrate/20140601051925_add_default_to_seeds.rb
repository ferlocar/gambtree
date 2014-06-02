class AddDefaultToSeeds < ActiveRecord::Migration
  def change
    change_column :users, :seeds, :integer, :default => 30
  end
end
