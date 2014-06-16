class HomeController < ApplicationController
  def index
    @show_tutorial = !cookies[:has_visited]
    cookies.permanent[:has_visited] = true
  end
  
  def tutorial
  end
  
  def about
    @show_tutorial = true
  end
  
  def new_message
    @message = Message.new
  end

  def create_message
    @message = Message.new(params[:message])
    
    if @message.valid?
      ContactMailer.new_message(@message).deliver
      redirect_to(root_path, :notice => "Message was successfully sent.")
    else
      flash.now.alert = "Please fill all fields."
      render :new
    end
  end
end
