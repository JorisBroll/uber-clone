class Admin::UsersController < ApplicationController
  	before_action :admins_only

  	include UsersHelper

	def index
		@clients = User.where("account_type = ?", User.account_types[:client])

		@users_selfemployed_admins = []
		@partners_selfemployed = Partner.where("status = ?", Partner.statuses[:self_employed]).each do |partner|
			partner.users.where("account_type = ?", User.account_types[:partneradmin]).each do |user| @users_selfemployed_admins.push(user) end
		end

		@users_sarl_admins = []
		@partners_selfemployed = Partner.where("status = ?", Partner.statuses[:company]).each do |partner|
			partner.users.where("account_type = ?", User.account_types[:partneradmin]).each do |user| @users_sarl_admins.push(user) end
		end

		@admins = User.where("account_type in (?)", [ User.account_types[:superadmin], User.account_types[:admin] ])
	end
	def show
		#current_partner
		@user = User.find(params[:id])
		@promocode = Promocode.find(2)
	end
	def new
		@user = User.new()
	end
	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "L'utilisateur "+build_name(@user, true)+" a été crée."
			update_user_companies
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'user', 'id' => @user.id.to_s} })
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
		
		update_user_companies # If set
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
		    	params.require(:user).permit(:name, :last_name, :email, :phone, :cellphone, :photo, :account_type, :address, :postcode, :city, :password, :password_confirmation, :partner_id, :promocode_id, :created_by)
		    end

		    def set_partner
		    	@partner = Partner.find(params[:partner_id])
		    end

		    def correct_user # Make a user unable to edit anyone but himself
				@user = User.find(params[:id])
				redirect_to(root_url) unless current_user?(@user)
	        end

	        def update_user_companies
	        	if !params[:user][:companies].nil? and params[:user][:companies].count > 0
		        	a = []
		    		params[:user][:companies].each do |company|
		    			a.push(Company.find_by(id: company))
		    		end
					@user.update({'companies' => a})
				end
	        end

end
