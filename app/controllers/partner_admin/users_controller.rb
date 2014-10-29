class PartnerAdmin::UsersController < ApplicationController
  	before_action :partneradmins_only

	def index
		@users = current_partner.users || current_user.partner.users
		@clients = @users.where("account_type = ?", User.account_types[:client])
		@drivers = @users.where("account_type in (?)", [ User.account_types[:driver], User.account_types[:partneradmin] ])
	end
	def show
		@user = get_correct_user
	end
	def new
		@user = current_partner.users.build
	end
	def create
		@user = current_partner.users.build(user_params)
		
		if @user.save
			flash[:success] = "Le chauffeur "+@user.name+" a été crée."
			redirect_to partner_admin_users_path
	    else
	    	flash[:error] = "La création de le chauffeur a échouée."
			render 'new'
	    end
	end
	def edit
		@user = User.find(params[:id])
	end
	def update
		@user = get_correct_user
		if @user.update_attributes(user_params)
			flash[:success] = "Le chauffeur "+@user.name+" a été modifié avec succès."
			redirect_to partner_admin_users_path
		else
			render 'edit'
		end
	end
	def destroy
		@user = get_correct_user
	    @user.destroy
	    flash[:success] = "Utilisateur supprimé."
	    redirect_to partner_admin_users_path
	end

		private

		    def user_params
		    	params.require(:user).permit(:name, :last_name, :email, :phone, :cellphone, :photo, :account_type, :address, :postcode, :city, :password, :password_confirmation, :partner_id, :promocode_id, :created_by)
		    end

		    def get_correct_user # Make sure we don't get an outside user
				if !current_partner.users.find_by(id: params[:id]).nil?
					return user = current_partner.users.find(params[:id])
				else
					flash[:error] = "Aucun utilisateur trouvé."
					redirect_to partner_admin_users_path
				end
	        end

end
