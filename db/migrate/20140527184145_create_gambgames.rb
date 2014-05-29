class CreateGambgames < ActiveRecord::Migration
  def change
    create_table :gambgames do |t|
      t.datetime :date_finished
      t.integer :prize_paid
      t.integer :players_number
      t.integer :awards_won
      t.references :winner_gambfruit, index: true
      t.boolean :ongoing
      t.integer :current_prize
      t.integer :current_players_number

      t.timestamps
    end
  end
end
