# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
Gamble.delete_all
Gambgame.delete_all
JoinRequest.delete_all
Gambfruit.delete_all

num_users = 300

num_users.times do |id|
  new_usr = User.create full_name: "Test #{id}", username: "test#{id}", password: "asdfasdf",
                        password_confirmation: "asdfasdf", birth_date: Date.current, email: "test#{id}@test.com"
  puts "User #{id+1} created" 
end

Gambgame.create ongoing: true, current_players_number: 0

def gamble usr
  has_gambled = false 
  current_game = Gambgame.current
  while !has_gambled
    fruit = FRUITS.sample
    color = COLORS.sample
    number = rand(100)
    gambfruit = Gambfruit.find_or_create_by fruit: fruit, color: color, number: number
    unless current_game.gambles.find_by gambfruit_id: gambfruit.id
      Gamble.create won: false, user: usr, gambfruit: gambfruit, gambgame: current_game 
      usr.seeds -= 1
      usr.save
      current_game.current_players_number += 1
      current_game.save
      has_gambled = true
    end
  end
end

User.all.each do |usr|
  puts "#{usr.full_name} is deciding if he will gamble"
  gamble(usr) if rand(2) == 1
end
