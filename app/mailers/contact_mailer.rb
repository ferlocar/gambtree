class ContactMailer < ActionMailer::Base

  default :from => "gambtree@gmail.com"
  default :to => "gambtree@gmail.com"

  def new_message(message)
    @message = message
    mail(:subject => "Gambtree - #{message.subject}")
  end

end