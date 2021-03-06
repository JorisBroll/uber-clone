class Admin::CompaniesController < ApplicationController
  	before_action -> { requiredWeight User::Account_types[:partneradmin][:weight] }
	before_action -> { check_privileges }, only: [:show, :edit, :update, :destroy]

	def index
		if userWeight <= User::Account_types[:admin][:weight]
			@companies = Company.all
		else
			@companies = current_partner.companies
		end
	end
	def show
		@users = @company.users

		@date_week = []

		if !params['recap'].nil?
			@select_date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
			@date = {
				:start => @select_date.beginning_of_month,
				:end => @select_date.end_of_month
			}			
			(0..6).each do |i|
				@date_week[i] = {
					:start => @select_date.weeks_since(i).at_beginning_of_week,
					:end => @select_date.weeks_since(i).at_end_of_week
				}
			end
		elsif !params['date_start'].nil?
			@date = {
				:start => params['date_start'].to_date,
				:end => params['date_end'].to_date
			}
		else	
			@date = {
				:start => Time.zone.now.beginning_of_month,
				:end => Time.zone.now.end_of_month
			}
			(0..6).each do |i|
				@date_week[i] = {
					:start => Time.zone.now.beginning_of_month.weeks_since(i).at_beginning_of_week,
					:end => Time.zone.now.beginning_of_month.weeks_since(i).at_end_of_week
				}
			end
		end
		
		#@courses = Course.where("date_when >= ? AND date_when <= ? AND status = ?", @date[:start], @date[:end], Course.statuses[:done])
		#@courses_week = Course.where("date_when >= ? AND date_when <= ? AND status = ?", @date_week[:start], @date_week[:end], Course.statuses[:done])

	end
	def new
		@company = Company.new
	end
	def create
		@company = Company.new(company_params)
		if @company.save
			flash[:success] = "L'entreprise "+@company.name+" a été crée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'partner', 'id' => @company.id.to_s} })
			redirect_to admin_company_path(@company)
		else
			flash[:error] = "L'entreprise n'a pas pu être crée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'partner'} })
			render 'new'
	    end
	end
	def edit

	end
	def update
		if params[:company][:users]
			@user = User.find_by(id: params[:company][:users][:id])

			already_in = false
			@company.users.each do |user|
				if user.id == @user.id
					already_in = true
				end
			end
			@company.update({ 'users' => @company.users.push(@user) }) unless already_in
			flash[:success] = "L'utilisateur a été ajouté avec succès."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'partner', 'id' => @company.id.to_s} })
			redirect_to admin_company_path(@company)
		else
			if @company.update_attributes(company_params)
				flash[:success] = "L'entreprise "+@company.name+" a été modifiée avec succès."
				AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'partner', 'id' => @company.id.to_s} })
				redirect_to admin_company_path(@company)
			else
				render 'edit'
			end
		end
	end
	def destroy
		if params[:user_id]
			@user = User.find_by(id: params[:user_id])

			@keep = []
			@company.users.each do |user|
				if user.id != @user.id
					@keep.push(user)
				end
			end

			@company.update({'users' => @keep })
			flash[:success] = "Utilisateur détaché"
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'partner', 'id' => @company.id.to_s} })
			redirect_to admin_company_path(@company)
		else
			@company = Company.find_by(id: params[:id]).destroy
		    flash[:success] = "Entreprise supprimée."
		    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'partner', 'id' => params[:id]} })
		    redirect_to admin_companies_path
		end
	end

		private

		    def company_params
		    	params.require(:company).permit(:name, :email, :notes, :phone, :address, :postcode, :city, :company_code, :tva_number, :bookmanager, :partner_id, { :user_ids => [] })
		    end

		    def check_privileges
		    	if userWeight <= User::Account_types[:admin][:weight]
		    		@company = Company.find_by(id: params[:id])
		    	else
		    		@company = current_partner.companies.find_by(id: params[:id])
		    	end

		    	if @company.nil?
	    			flash[:error] = "Page inaccessible."
	    			redirect_to [:admin, 'home'] 
	    		end
		    end
end