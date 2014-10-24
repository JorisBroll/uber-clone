module SessionsHelper
  # current_user object creation
  def current_user=(user)
    @current_user = user
  end
  # Get the user_id from cookies and assign it
  def current_user
    @current_user ||= User.find_by(id: cookies[:user_id])
  end
  # Is this user the current user ?
  def current_user?(user)
    current_user == user
  end

  # Log in, log out
  def sign_in(user)
    if ['driver', 'client'].include? user.account_type
      return 'x1' # Not an admin or partneradim ? Byebye
    elsif user.account_type == 'partneradmin' && user.partner.nil?
      return 'x2' # No partner for this partneradmin => can't admin anything duh
    end
     
    cookies[:user_id] = user.id
    self.current_user = user
    if !user.partner.nil?
      self.current_partner = user.partner
      cookies[:partner_id] = user.partner.id
    end
    return true
  end

  def sign_out
    cookies.delete :user_id
    cookies.delete :partner_id
  end

  # Set partner variable for administration purposes
  def admin_this_partner(partner)
    self.current_partner = partner
    cookies[:partner_id] = partner.id
  end
  def sign_out_partner
    cookies.delete :partner_id
    self.current_partner = nil
  end
  def current_partner=(partner)
    @current_partner = partner
  end
  def current_partner
    if !current_user.partner.nil?
      @current_partner ||= current_user.partner
    elsif !cookies[:partner_id].nil?
      @current_partner = Partner.find_by(id: cookies[:partner_id])
    else
      return false
    end
  end
  # Is the admin using a partner id right now ?
  def currently_admining_partner?
    !cookies[:partner_id].nil?
  end

  # Check if signed in
  def signed_in?
    !current_user.nil?
  end

  # Admins or partneradmins
  def is_superadmin?
    current_user.account_type == 'superadmin'
  end
  def is_admin?
    current_user.account_type == 'admin'
  end
  def is_partneradmin?
    current_user.account_type == 'partneradmin'
  end

  def superadmins_only
    if current_user.account_type != 'superadmin'
      flash[:error] = "Vous devez être gérant pour consulter cette page."
      redirect_to(root_url)
    end
  end

  def admins_only
    if current_user.account_type != 'admin' && current_user.account_type != 'superadmin'
      flash[:error] = "Vous devez être admin pour consulter cette page."
      redirect_to(root_url)
    end
  end

  def partneradmins_only
      if current_user.account_type != 'partneradmin' && current_user.account_type != 'admin' && current_user.account_type != 'superadmin'
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

  def user_home
    if is_superadmin?
      return admin_home_path
    elsif is_admin?
      return admin_home_path
    elsif is_partneradmin?
      return partner_admin_home_path
    end
  end

end