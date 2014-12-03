class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  before_action :set_locale

  include SessionsHelper

  layout 'login', only: [:login]

  def login
    if signed_in?
      redirect_to admin_home_path
    end
  end

    private

      def set_locale
        I18n.locale = :fr
      end

      def to_bool(str)
        if str == 'true' || str == '1' || str == true then return true end
      end
end
