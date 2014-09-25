class SessionsController < ApplicationController
	def create
		user = User.find_by(email: params[:session][:email].downcase)
  		
  		if user && user.authenticate(params[:session][:password])
			sign_in user
			if is_superadmin?
				redirect_to(root_url)
			elsif is_partneradmin?
				if user.partner.nil?
					flash[:error] = "Ce compte chauffeur n'est associé à aucune entreprise partenaire. Veuillez contacter Naveco pour résoudre le problème."
					redirect_to '/login'
				else
					redirect_to partner_admin_path(user.partner)
				end
			else
				sign_out
				flash[:error] = "Vous n'avez pas les privilèges nécessaires"
				redirect_to '/login'
			end
		else
			flash[:error] = "Votre authentification a échouée."
			redirect_to '/login'
		end
	end
end
