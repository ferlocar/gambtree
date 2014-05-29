class Gamble < ActiveRecord::Base
  belongs_to :user
  belongs_to :gambgame
  belongs_to :gambfruit
end
