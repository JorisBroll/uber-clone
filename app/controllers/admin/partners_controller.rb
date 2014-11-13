class Admin::PartnersController < ApplicationController
	before_action :partneradmins_only, :only => [:edit, :update]
	before_action :admins_only, :except => [:edit, :update]

	include UploadsHelper

	def index
		@partners = Partner.all
	end
	def show
		@partner = Partner.find(params[:id])
		admin_this_partner @partner
		redirect_to partner_admin_home_path
	end
	def new
		@partner = Partner.new
	end
	def create
		store_logo

		@partner = Partner.new(partner_params)
		if @partner.save
			update_logo(@partner)
			flash[:success] = "L'entreprise "+@partner.name+" a été créée."
			redirect_to admin_partners_path
	    else
	    	flash[:error] = "L'entreprise n'a pas pu être créée."
	    	render 'new'
	    end
	end
	def edit
		@partner = Partner.find(params[:id])
	end
	def update
		store_logo

		@partner = Partner.find(params[:id])
		if @partner.update_attributes(partner_params)
			update_logo(@partner)
			flash[:success] = "L'entreprise "+@partner.name+" a été modifiée avec succès."
			if is_partneradmin?
				redirect_to partner_admin_home_path
			else
				redirect_to admin_partners_path
			end
		else
			render 'edit'
		end
	end
	def destroy
	    Partner.find(params[:id]).destroy
	    flash[:success] = "Entreprise partenaire supprimée."
	    redirect_to admin_partners_path
	end

		private

		    def partner_params
		    	params.require(:partner).permit(:name, :email, :phone, :company_code, :tva_number, :note, :address, :postcode, :city, :status, :logo)
		    end

		    def update_logo(partner)
	        	if logo_name = save_photo(@logo, 'partner'+partner.id.to_s)
	        		@partner.update_attributes(logo: logo_name)
	        	end
	        end

	        def store_logo
				@logo = params[:partner][:logo]
				params[:partner][:logo] = ""
	        end

end
