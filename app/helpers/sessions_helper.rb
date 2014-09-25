module SessionsHelper
  # current_user object creation
  def current_user=(user)
    @current_user = user
  end
  def current_user?(user)
    current_user == user
  end
  # Get the user_id from cookies and assign it
  def current_user
    @current_user ||= User.find_by(id: cookies[:user_id])
  end

  # Log in, log out
  def sign_in(user)
    cookies[:user_id] = user.id
    self.current_user = user
  end
  def sign_out
    cookies[:user_id] = nil
    self.current_user = nil
  end

  # Check if signed in
  def signed_in?
    !current_user.nil?
  end

  # Admins or partneradmins
  def is_superadmin?
    current_user.account_type == 'admin'
  end
  def is_partneradmin?
    current_user.account_type == 'partneradmin'
  end

  def superadmins_only
    if current_user.account_type != 'admin'
      flash[:error] = "Vous devez être admin pour consulter cette page."
      redirect_to(root_url)
    end
  end

  def admins_only
      if current_user.account_type != 'partneradmin' && current_user.account_type != 'admin'
        flash[:error] = "Vous devez être partenaire pour consulter cette page."
        redirect_to(root_url)
      end
  end

  def partner_users_only
      if !current_user.partner.nil? && params[:partner_id] == current_user.partner.id
        flash[:error] = "Vous ne pouvez éditer que votre entreprise."
        redirect_to(partner_path(params[:partner_id]))
      end
  end

  def is_under_partner
      if !current_user.partner.nil?
        flash[:error] = "Vous n'êtes affilié à aucune entreprise. Veuillez contacter Naveco pour résoudre ce problème"
        redirect_to(root_url)
      end
  end

end