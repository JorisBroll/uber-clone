class Admin::PromocodesController < ApplicationController
	before_action :admins_only

	def index
		@promocodes = Promocode.all
	end
	def show
		#current_partner
		@promocode = Promocode.find(params[:id])
	end
	def new
		@promocode = Promocode.new()
	end
	def create
		@promocode = Promocode.new(promocode_params)
		if @promocode.save
			flash[:success] = "Le code promotion \""+@promocode.name+"\" a été crée."
			redirect_to admin_promocodes_path
		else
			flash[:error] = "Le code promotion n'a pas pu être crée."
			render 'new'
	    end
	end
	def edit
		@promocode = Promocode.find(params[:id])
	end
	def update
		@promocode = Promocode.find(params[:id])
		if @promocode.update_attributes(promocode_params)
			flash[:success] = "L'utilisateur "+@promocode.name+" a été modifié avec succès."
			redirect_to admin_promocodes_path
		else
			render 'edit'
		end
	end
	def destroy
	    Promocode.find(params[:id]).destroy
	    flash[:success] = "Utilisateur supprimé."
	    redirect_to admin_promocodes_path
	end

		private

		    def promocode_params
		    	params.require(:promocode).permit(:name, :effect_type, :effect_type_value, :effect_length, :effect_length_value)
		    end

		    def set_partner
		    	@partner = Partner.find(params[:partner_id])
		    end

		    def correct_promocode # Make a promocode unable to edit anyone but himself
				@promocode = Promocode.find(params[:id])
				redirect_to(root_url) unless current_promocode?(@promocode)
	        end
end
