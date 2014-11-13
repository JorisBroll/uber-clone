class Admin::CompaniesController < ApplicationController
  	before_action :admins_only

	def index
		@companies = Company.all
	end
	def show
		@company = Company.find_by(id: params[:id])
		@users = @company.users
	end
	def new
		@company = Company.new()
	end
	def create
		@company = Company.new(company_params)
		if @company.save
			flash[:success] = "L'entreprise "+@company.name+" a été crée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'partner', 'id' => @company.id.to_s} })
			redirect_to admin_companies_path
		else
			flash[:error] = "L'entreprise n'a pas pu être crée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'partner'} })
			render 'new'
	    end
	end
	def edit
		@company = Company.find_by(id: params[:id])
	end
	def update
		@company = Company.find_by(id: params[:id])
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
				redirect_to admin_companies_path
			else
				render 'edit'
			end
		end
	end
	def destroy
		if params[:user_id]
			@company = Company.find_by(id: params[:company_id])
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
		    	params.require(:company).permit(:name, :notes, :phone, :address, :postcode, :city, :company_code, :tva_number, :bookmanager, :partner_id, { :user_ids => [] })
		    end

		   
end