class Admin::PartnersController < ApplicationController
	before_action :superadmins_only

	def index
		@partners = Partner.all
	end
	def show
		@partner = Partner.find(params[:id])
	end
	def new
		@partner = Partner.new
	end
	def create
		@partner = Partner.new(partner_params)
		if @partner.save
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
		@partner = Partner.find(params[:id])
		if @partner.update_attributes(partner_params)
			flash[:success] = "L'entreprise "+@partner.name+" a été modifiée avec succès."
			redirect_to admin_partner_path(@partner)
		else
			render 'edit'
		end
	end
	def destroy
	    Partner.find(params[:id]).destroy
	    flash[:success] = "Entreprise partenaire supprimée."
	    redirect_to partners_url
	end

		private

		    def partner_params
		    	params.require(:partner).permit(:name, :email, :note)
		    end

end
