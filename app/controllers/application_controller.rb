class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  before_action :set_locale

def sign_in(user)
    cookies[:user_id] = user.id
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end
  def current_user?(user)
    current_user == user
  end

  def current_user
    @current_user ||= User.find_by(id: cookies[:user_id])
  end

  #include SessionsHelper

  layout 'login', only: [:login]
  def login

  end

  def home
  	#if !signed_in?
  		redirect_to '/login'
  	#end
  end

    private
      def set_locale
        I18n.locale = :fr
      end
end
