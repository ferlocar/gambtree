class ContactMailer < ActionMailer::Base

  default :from => "ferlocar.tec@gmail.com"
  default :to => "ferlocar.tec@gmail.com"

  def new_message(message)
    @message = message
    mail(:subject => "Gambtree - #{message.subject}")
  end

end