FactoryGirl.define do
  
  factory :gamble do |f| 
    gambfruit
    user
    f.gambgame Gambgame.current
    
    factory :old_gamble do |f_old| 
      gambgame
    end
  end
  
end 