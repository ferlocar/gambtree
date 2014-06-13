class HomeController < ApplicationController
  def index
    @show_tutorial = !cookies[:has_visited]
    cookies.permanent[:has_visited] = true
  end
  
  def tutorial
    
  end
end
