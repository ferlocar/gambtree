Thread.new do
  loop do
    puts "Checking if the Gambgame has ended."
    GambgameController.check_ongoing_gambgame
    sleep 60
  end
end