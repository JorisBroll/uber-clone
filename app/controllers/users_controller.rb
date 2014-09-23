class UsersController < ApplicationController
	before_action :signed_in_user
  	#before_action :correct_user
  	before_action :drivers_only
  	before_action :password_check, only: [:update]
		

	def index
		@users = User.all
	end
	def new
		@user = User.new
	end
	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "L'utilisateur "+@user.name+" a été crée."
			redirect_to users_path
	    else
	    	render 'new'
	    end
	end
	def edit
		@user = User.find(params[:id])
	end
	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params) # check if the user updating is indeed updating himself
			flash[:success] = "L'utilisateur "+@user.name+" a été modifié avec succès."
			redirect_to users_path
		else
			render 'edit'
		end
	end
	def destroy
	    User.find(params[:id]).destroy
	    flash[:success] = "Utilisateur supprimé."
	    redirect_to users_url
	end

		private

		    def user_params
		    	params.require(:user).permit(:name, :email, :account_type, :password, :password_confirmation)
		    end
		    def password_check
		    	if params[:user][:password].blank?
		    		params[:user].delete :password
		    		params[:user].delete :confirmation
		    	end
		    end


		    # Before filters

		    def signed_in_user
		    	redirect_to '/login' unless signed_in?
		    end
		    def correct_user # Make a user unable to edit anyone but himself
				@user = User.find(params[:id])
				redirect_to(root_url) unless current_user?(@user)
	        end
end
