class CreateJoinRequests < ActiveRecord::Migration
  def change
    create_table :join_requests do |t|
      t.references :user, index: true
      t.datetime :date_issued
      t.references :receiver, index: true
      t.boolean :resolved
      t.datetime :date_resolved

      t.timestamps
    end
  end
end
