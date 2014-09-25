class PartnerAdmin::UsersController < ApplicationController
  	before_action :admins_only

	def index
		@users = current_user.partner.users
	end
	def show
		@user = User.find(params[:id])
	end
	def new
		set_partner
		@user = @partner.users.build
	end
	def create
		set_partner
		@user = @partner.users.build(user_params)
		
		if @user.save
			flash[:success] = "L'utilisateur "+@user.name+" a été crée."
			redirect_to partner_admin_users_path
	    else
	    	flash[:error] = "La création de l'utilisateur a échouée."
			render 'new'
	    end
	end
	def edit
		@user = User.find(params[:id])
	end
	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "L'utilisateur "+@user.name+" a été modifié avec succès."
			redirect_to partner_users_path
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

		    def set_partner
		    	@partner = current_user.partner
		    end

		    def correct_user # Make a user unable to edit anyone but himself
				@user = User.find(params[:id])
				redirect_to(root_url) unless current_user?(@user)
	        end
end
