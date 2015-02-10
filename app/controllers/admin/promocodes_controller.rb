class Admin::PromocodesController < ApplicationController
	before_action -> { requiredWeight User::Account_types[:admin][:weight] }
	
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
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			redirect_to admin_promocode_path(@promocode)
		else
			flash[:error] = "Le code promotion n'a pas pu être crée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'promocode'} })
			render 'new'
	    end
	end
	def edit
		@promocode = Promocode.find(params[:id])
	end
	def update
		@promocode = Promocode.find(params[:id])
		if @promocode.update_attributes(promocode_params)
			flash[:success] = "Le code promotion "+@promocode.name+" a été modifié avec succès."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			redirect_to admin_promocode_path(@promocode)
		else
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_updated', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			render 'edit'
		end
	end
	def destroy
	    Promocode.find(params[:id]).destroy
	    flash[:success] = "Code promo supprimé."
	    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'promocode', 'id' => params[:id].to_s} })
	    redirect_to admin_promocodes_path
	end

		private

		    def promocode_params
		    	params.require(:promocode).permit(:name, :code, :effect_type, :effect_type_value, :effect_length, :effect_length_value, :created_at)
		    end

		    def set_partner
		    	@partner = Partner.find(params[:partner_id])
		    end

		    def correct_promocode # Make a promocode unable to edit anyone but himself
				@promocode = Promocode.find(params[:id])
				redirect_to(root_url) unless current_promocode?(@promocode)
	        end
end
