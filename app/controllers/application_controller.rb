class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  protected

  def configure_devise_permitted_parameters
    registration_params = [:full_name, :birth_date, :username, :email, :password, :password_confirmation]

    if params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) { 
        |u| u.permit(registration_params << :current_password)
      }
    elsif params[:action] == 'create'
      if params.has_key?(:user) && !params[:user][:recommender].blank?
        recommender = User.find_by username: params[:user][:recommender]
        if recommender.nil?
          flash[:error] = "Recommender '#{params[:user][:recommender]}' does not exist."
          redirect_to new_user_registration_path
        else
          params[:user][:recommender_id] = recommender.id
          registration_params << :recommender_id
        end
      end
      devise_parameter_sanitizer.for(:sign_up) { 
        |u| u.permit(registration_params) 
      }
    end
  end
end
