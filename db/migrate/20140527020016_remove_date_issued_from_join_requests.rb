class RemoveDateIssuedFromJoinRequests < ActiveRecord::Migration
  def change
    remove_column :join_requests, :date_issued, :datetime
  end
end
