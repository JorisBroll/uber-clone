class Admin::UsersController < ApplicationController
  	before_action :admins_only

  	include UsersHelper

	def index
		@clients = User.where("account_type = ?", User.account_types[:client])
		@drivers = User.where("account_type = ?", User.account_types[:driver])
		@partneradmins = User.where("account_type = ?", User.account_types[:partneradmin])
		@admins = User.where("account_type in (?)", [ User.account_types[:superadmin], User.account_types[:admin] ])
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
			flash[:success] = "L'utilisateur "+build_name(@user, true)+" a été crée."
			#AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'user', 'id' => @user.id.to_s} })
			redirect_to admin_users_path
		else
			flash[:error] = "L'utilisateur n'a pas pu être crée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'user'} })
			render 'new'
	    end
	end
	def edit
		@user = User.find(params[:id])
		@partners = Partner.all
	end
	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "L'utilisateur "+build_name(@user, true)+" a été modifié avec succès."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'user', 'id' => @user.id.to_s} })
			redirect_to admin_users_path
		else
			flash[:error] = "L'utilisateur "+build_name(@user, true)+" n'a pas pu être modifié."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_updated', 'target_object' => {'type' => 'user', 'id' => @user.id.to_s} })
			render 'edit'
		end
	end
	def destroy
		if ['1', '2', '3'].include? params[:id]
			flash[:notice] = "Utilisateur protégé. Il ne peut être supprimé."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_deleted', 'target_object' => {'type' => 'user', 'id' => params[:id].to_s} })
		else
		    User.find(params[:id]).destroy
		    flash[:success] = "Utilisateur supprimé."
		    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'user', 'id' => params[:id].to_s} })
		end
	    redirect_to admin_users_path
	end

		private

		    def user_params
		    	params.require(:user).permit(:name, :last_name, :email, :phone, :photo, :account_type, :address, :postcode, :password, :password_confirmation, :partner_id, :promocode_id, :created_by)
		    end

		    def set_partner
		    	@partner = Partner.find(params[:partner_id])
		    end

		    def correct_user # Make a user unable to edit anyone but himself
				@user = User.find(params[:id])
				redirect_to(root_url) unless current_user?(@user)
	        end

end
