class Admin::UsersController < ApplicationController
  	before_action :superadmins_only

	def index
		@users = User.all
	end
	def show
		#current_partner
		@user = User.find(params[:id])
	end
	def new
		@user = User.new()
	end
	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "L'utilisateur "+@user.name+" a été crée."
			redirect_to admin_users_path
		else
			flash[:error] = "L'utilisateur n'a pas pu être crée."
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
			redirect_to admin_users_path
		else
			render 'edit'
		end
	end
	def destroy
	    User.find(params[:id]).destroy
	    flash[:success] = "Utilisateur supprimé."
	    redirect_to admin_users_path
	end

		private

		    def user_params
		    	params.require(:user).permit(:name, :email, :account_type, :password, :password_confirmation)
		    end

		    def set_partner
		    	@partner = Partner.find(params[:partner_id])
		    end

		    def correct_user # Make a user unable to edit anyone but himself
				@user = User.find(params[:id])
				redirect_to(root_url) unless current_user?(@user)
	        end
end
