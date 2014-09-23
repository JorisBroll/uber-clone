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

  def redirect_nonadmins
    if current_user.account_type != 'admin'
      flash[:error] = "Vous devez être admin pour consulter cette page."
      redirect_to(root_url)
    end
  end

  def redirect_nonpartners
      if current_user.account_type != 'driver'
        flash[:error] = "Vous devez être partenaire pour consulter cette page."
        redirect_to(root_url)
      end
  end

end