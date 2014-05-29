class Gambgame < ActiveRecord::Base
  belongs_to :winner_gambfruit, :class_name => 'Gambfruit'
  has_many :gambles
  
  def self.current 
    Gambgame.find_by ongoing: true
  end
  
  def prize
    total_income = current_players_number * SEED_FEE
    gambtree_share = TARGET_MARGIN * [1, current_players_number/PLAYER_TARGET].min
    maximum_awards = Math.log2(current_players_number+1)
    (total_income * (1 - gambtree_share) / (maximum_awards * COIN_PRICE)).round 0
  end
  
end
