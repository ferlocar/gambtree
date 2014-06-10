class AddLastGambseedGiftDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_gambseed_gift_date, :datetime
  end
end
