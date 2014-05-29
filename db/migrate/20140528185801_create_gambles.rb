class CreateGambles < ActiveRecord::Migration
  def change
    create_table :gambles do |t|
      t.boolean :won
      t.references :user, index: true
      t.references :gambgame, index: true
      t.references :gambfruit, index: true

      t.timestamps
    end
  end
end
