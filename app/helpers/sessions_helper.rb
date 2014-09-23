module SessionsHelper
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
end