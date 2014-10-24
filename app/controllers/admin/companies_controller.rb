class Admin::CompaniesController < ApplicationController
  	before_action :admins_only

	def index
		@companies = Company.all
	end
	def show
		@company = Company.find(params[:id])
	end
	def new
		@company = Company.new()
	end
	def create
		@company = Company.new(company_params)
		if @company.save
			flash[:success] = "L'entreprise "+@company.name+" a été crée."
			redirect_to admin_companies_path
		else
			flash[:error] = "L'entreprise n'a pas pu être crée."
			render 'new'
	    end
	end
	def edit
		@company = Company.find_by(id: params[:id])
		@partners = Partner.all
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
			redirect_to admin_company_path(@company)
		end
		#if @company.update_attributes(company_params)
		#	flash[:success] = "L'entreprise "+@company.name+" a été modifiée avec succès."
		#	redirect_to admin_companies_path
		#else
		#	render 'edit'
		#end
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
			redirect_to admin_company_path(@company)
		else
			@company = Company.find_by(id: params[:id])
		    #Company.find(params[:id]).destroy
		    #flash[:success] = "Entreprise supprimée."
		    #redirect_to admin_companies_path
		end
	end

		private

		    def company_params
		    	params.require(:company).permit(:name, :notes, {:user_ids => []})
		    end

		   
end