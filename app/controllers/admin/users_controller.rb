class Admin::UsersController < ApplicationController
	before_action -> { requiredWeight User::Account_types[:partneradmin][:weight] }
	before_action -> { check_privileges }, only: [:show, :edit, :update, :destroy]
	before_action -> { protect_destroy }, only: [:destroy]

  	include UsersHelper
  	include UploadsHelper
  	include CoursesHelper

	def index
		if userWeight <= User::Account_types[:admin][:weight]
			@driversToEnable = User.where("account_type = ? AND enabled = false", User.account_types[:driver])
			
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
		else
			@clients = current_partner.users
			render 'partner_index'
		end
	end
	def show
		@companies = @user.companies
		@promocodes = @user.promocodes
		@date = []
		@chartData = []
		@userEarnTotal = []
		@courses = []

		if !params['recap'].nil?
			@select_date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
			(1..12).each do |i|				
				@date[i] = {
					:start => @select_date.prev_month(i-1).beginning_of_month,
					:end => @select_date.prev_month(i-1).end_of_month
				}
				@courses[i] = @user.courses.where("date_when >= ? AND date_when <= ? AND status = ?", @date[i][:start], @date[i][:end], Course.statuses[:done])
			end

			(0..11).each do |i|
				@chartData[i] = {:money => (@courses[i+1].map {|s| price_afterExtras(s)}.reduce(0, :+).round(2)), :months => @date[i+1][:start].strftime("%m/%Y"), :id => i+1}
			end
			@chartData = @chartData.sort_by{|e| -e[:id]}
		else	
			(0..12).each do |i|
				@date[i] = {
					:start => Date.today.prev_month(i-1).beginning_of_month,
					:end => Date.today.prev_month(i-1).end_of_month
				}
				@courses[i] = @user.courses.where("date_when >= ? AND date_when <= ? AND status = ?", @date[i][:start], @date[i][:end], Course.statuses[:done])
			end
			(0..11).each do |i|
				@chartData[i] = {:money => (@courses[i+1].map {|s| price_afterExtras(s)}.reduce(0, :+).round(2)), :months => @date[i+1][:start].strftime("%m/%Y"), :id => i}
				@userEarnTotal[i] = @courses[i+1].map {|s| price_afterExtras(s)}.reduce(0, :+).round(2)
			end	
			@chartData = @chartData.sort_by{|e| -e[:id]}
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

	end
	def update
		store_photo

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
		    @user.destroy
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

	        def update_photo(user)
	        	if photo_name = save_photo(@photo, 'user'+user.id.to_s)
	        		@user.update_attributes(photo: photo_name)
	        	end
	        end

	        def store_photo
				@photo = params[:user][:photo]
				params[:user][:photo] = ""
	        end

	        def check_privileges
				if userWeight <= User::Account_types[:admin][:weight]
					@user = User.find_by(id: params[:id])
				else
					@user = current_partner.users.find_by(id: params[:id])
				end

				if @user.nil?
					flash[:error] = "Page inaccessible."
					redirect_to [:admin, 'home'] 
				end
			end

			def protect_destroy
				if userWeight < User::Account_types[:superadmin][:weight]
					flash[:error] = "Page inaccessible."
					redirect_to [:admin, 'home'] 
				end
			end
end
