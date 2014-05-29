class CreateGambfruits < ActiveRecord::Migration
  def change
    create_table :gambfruits do |t|
      t.string :color
      t.string :fruit
      t.integer :number

      t.timestamps
    end
  end
end
