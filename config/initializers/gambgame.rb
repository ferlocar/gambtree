Thread.new do
  begin
    loop do
      puts "Checking if the Gambgame has ended."
      GambgameController.check_ongoing_gambgame
      sleep 60
    end
  rescue Exception => e
    puts "Could not check Gambgame. A problem with database perhaps?"
    puts e.message
  end
end