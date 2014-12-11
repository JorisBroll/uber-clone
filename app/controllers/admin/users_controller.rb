class Admin::UsersController < ApplicationController
  	before_action :admins_only

  	include UsersHelper
  	include UploadsHelper

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
		@companies = @user.companies
		@promocodes = @user.promocodes

		if !params['recap'].nil?
			@select_date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
			@date = {
				:start => @select_date.beginning_of_month,
				:end => @select_date.end_of_month
			}
			@dates = {
				:start => @select_date.prev_month.beginning_of_month,
				:end => @select_date.prev_month.end_of_month
			}
			@datess = {
				:start => @select_date.prev_month(2).beginning_of_month,
				:end => @select_date.prev_month(2).end_of_month
			}

			@courses = []

			(1..5).each do |i|
				
				@date[i] = {
					:start => @select_date.prev_month(i).beginning_of_month,
					:end => @select_date.prev_month(i).end_of_month
				}

				@courses[i] = @user.courses.where("date_when >= ? AND date_when <= ? AND status = ?", @date[i][:start], @date[i][:end], Course.statuses[:done])

			end


			#(1..5).each do |i|

			#@chartData = [
				
			#	{:geekbench => @courses.map {|s| price_afterPromo(s)}.reduce(0, :+).round(2) },
				
			#]

			#end

			

		else	
			@date = {
				:start => Time.zone.now.beginning_of_month,
				:end => Time.zone.now.end_of_month
			}
		end

	end
	def new
		@user = User.new()
	end
	def create
		store_photo

		@user = User.new(user_params)
		if @user.save
			update_photo(@user)
			flash[:success] = "L'utilisateur "+build_name(@user, true)+" a été crée."
			Log.create(user_id: current_user.id, target_type: 0, target_id: @user.id, action: 'create')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'user', 'id' => @user.id.to_s} })
			redirect_to admin_users_path
		else
			flash[:error] = "L'utilisateur n'a pas pu être crée."
			AppLogger.log ({ 'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'user'} })
			render 'new'
	    end
	end
	def edit
		@user = User.find(params[:id])
		@partners = Partner.all
	end
	def update
		store_photo

		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			update_photo(@user)
			flash[:success] = "L'utilisateur "+build_name(@user, true)+" a été modifié avec succès."
			Log.create(user_id: current_user.id, target_type: 0, target_id: @user.id, action: 'update')
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
			Log.create(user_id: current_user.id, target_type: 0, target_id: @user.id, action: 'destroy_fail', extra: '(Utilisateur protégé)')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_deleted', 'target_object' => {'type' => 'user', 'id' => params[:id].to_s} })
		else
		    User.find(params[:id]).destroy
		    flash[:success] = "Utilisateur supprimé."
		    Log.create(user_id: current_user.id, target_type: 0, target_id: params[:id], action: 'destroy')
		    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'user', 'id' => params[:id].to_s} })
		end
	    redirect_to admin_users_path
	end

		private

		    def user_params
		    	params.require(:user).permit(:name, :last_name, :email, :phone, :cellphone, :photo, :account_type, :address, :postcode, :city, :password, :password_confirmation, :partner_id, {:promocode_ids => []}, {:company_ids => []}, :enabled)
		    end

		    def set_partner
		    	@partner = Partner.find(params[:partner_id])
		    end

		    def correct_user # Make a user unable to edit anyone but himself
				@user = User.find(params[:id])
				redirect_to(root_url) unless current_user?(@user)
	        end

	        def update_photo(user)
	        	if photo_name = save_photo(@photo, 'user'+user.id.to_s)
	        		@user.update_attributes(photo: photo_name)
	        	end
	        end

	        def store_photo
				@photo = params[:user][:photo]
				params[:user][:photo] = ""
	        end
end
