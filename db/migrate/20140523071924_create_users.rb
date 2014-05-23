class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :full_name
      t.string :email
      t.binary :password
      t.date :birth_date
      t.integer :seeds
      t.integer :coins
      t.references :recommender, index: true
      t.references :parent, index: true
      t.references :left_branch, index: true
      t.references :right_branch, index: true

      t.timestamps
    end
  end
end
