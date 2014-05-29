class GambgameController < ApplicationController
  before_action :authenticate_user!
  @@cheking = false
  
  def play
  end
  
  def gamble
    errors = []
    if current_user.seeds > 0
      # Gambfruit parameter validations
      fruit = params[:fruit]
      color = params[:color]
      numberParam = params[:number] || ""
      number = numberParam.to_i
      unless FRUITS.include?(fruit)
        errors << "You put an invalid type of fruit for your Gambfruit."
      end
      unless COLORS.include?(color)
        errors <<  "You put an invalid color for your Gambfruit."
      end
      unless numberParam.is_i? && number >= 0 && number < 100
        errors << "You put an invalid number for your Gambfruit."
      end 
      
      unless errors.any?
        # User gambles' validation
        current_game = Gambgame.current
        unless current_game.gambles.find_by user_id: current_user.id
          # Gambfruit validation
          gambfruit = Gambfruit.find_or_create_by fruit: fruit, color: color, number: number
          unless current_game.gambles.find_by gambfruit_id: gambfruit.id
            Gamble.create won: false, user: current_user, gambfruit: gambfruit, gambgame: current_game 
            
            current_user.seeds -= 1
            current_user.save
            
            current_game.current_players_number += 1
            current_game.save
          else
            errors << "The gambfruit you picked was already chosen by someone else."
          end
        else
          errors << "You already placed a gamble in today's Gambgame."
        end
      end
    else
      errors << "You do not have a Gambseed to participate."
    end
    
    if errors.any?
      flash[:error] = errors.first
      redirect_to gambgame_play_path
    else
      redirect_to root_path
    end
  end
  
  def self.check_ongoing_gambgame
    return if @@cheking
    @@cheking = true
    
    while true
      current_gambgame = Gambgame.find_by ongoing: true
      if current_gambgame.nil? || (current_gambgame.created_at + 1.days) < Time.now
        
        # Finish current gambgame
        unless current_gambgame.nil?
          determine_winners
          current_gambgame.ongoing = false
          current_gambgame.date_finished = Time.now
          current_gambgame.prize_paid = current_gambgame.prize
          current_gambgame.current_players_number = current_gambgame.current_players_number
          current_gambgame.save
        end
        
        # Start new gambgame
        Gambgame.create ongoing: true, current_players_number: 0
      end
      sleep 60
    end
  end
  
  #protected
  
  def self.determine_winners
    current_game =  Gambgame.current 
    gambles = current_game.gambles
    winner_position = RandomGenerator.get_random_int gambles.length - 1
    winner_gamble = gambles[winner_position]
    
    winner_players = [winner_gamble.user] + winner_gamble.user.get_winner_parents
    winner_players.each do |player|
      player.coins += current_game.prize
      player.save
    end
    current_game.awards_won = winner_players.length
    current_game.winner_gambfruit = winner_gamble.gambfruit
    current_game.save
  end
  
end
