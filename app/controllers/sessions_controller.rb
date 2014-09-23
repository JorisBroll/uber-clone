class SessionsController < ApplicationController
	def create
		user = User.find_by(email: params[:session][:email].downcase)
  		
  		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_to(root_url)
		else
			flash[:error] = "Votre authentification a échouée."
			redirect_to '/login'
		end
	end

	def test
	end
end
