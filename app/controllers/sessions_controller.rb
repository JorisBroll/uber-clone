class SessionsController < ApplicationController
	def create
		user = User.find_by(email: params[:session][:email].downcase)
  		
  		if user && user.authenticate(params[:session][:password])
			case sign_in user
			when true
				redirect_to admin_home_path
			when 'x1'
				flash[:error] = "Votre authentification a échouée. Vous n'avez peut-être pas les privilèges nécessaires."
				redirect_to '/login'
			when 'x2'
				flash[:error] = "Ce compte chauffeur n'est associé à aucune entreprise partenaire. Veuillez contacter Naveco pour résoudre le problème."
				redirect_to '/login'
			else
				flash[:error] = "Votre authentification a échouée."
				redirect_to '/login'
			end
		else
			flash[:error] = "Votre authentification a échouée : aucun compte trouvé."
			redirect_to '/login'
		end
	end

	def destroy
		sign_out
		redirect_to '/login'
	end
end
