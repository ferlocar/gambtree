class Gambgame < ActiveRecord::Base
  belongs_to :winner_gambfruit, :class_name => 'Gambfruit'
  has_many :gambles
  
  def self.current 
    Gambgame.find_by ongoing: true
  end
  
  def prize
    Gambgame.prize_for_players current_players_number
  end
  
  def self.prize_for_players num_players
    return 0 unless num_players > 0
    total_income = num_players * SEED_FEE
    gambtree_share = TARGET_MARGIN * [1, num_players/PLAYER_TARGET].min
    maximum_awards = Math.log2(num_players+1)
    prize_formula = (total_income * (1 - gambtree_share) / (maximum_awards * COIN_PRICE)).round 0
    return [prize_formula, Gambgame.prize_for_players(num_players - 1) + 1].max
  end
  
  def prize_increase
    Gambgame.prize_for_players(current_players_number + 1) - prize
  end
  
  def winners
    User.joins(:gambles).where(gambles: {gambgame: self, won: true}).order("username")
  end
  
end
