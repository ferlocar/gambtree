FactoryGirl.define do 
  sequence(:number) {|n| (n-1)%100}
  sequence(:fruit) {|n| FRUITS[((n-1)%500)/100]}
  sequence(:color) {|n| COLORS[(n-1)/500]}
  
  factory :gambfruit do |f|
    color
    number
    fruit    
  end
end 