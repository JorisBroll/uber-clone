class Admin::PartnersController < ApplicationController
	before_action -> { requiredWeight User::Account_types[:partneradmin][:weight] }
	before_action -> { check_privileges }, only: [:show, :edit, :update, :destroy]
	before_action -> { protect_destroy }, only: [:destroy]

	include UploadsHelper

	def index
		sign_out_partner
		if userWeight <= User::Account_types[:admin][:weight]
			@partners = Partner.all
		else
			redirect_to admin_partner_path(current_partner)
		end
	end
	def show
		admin_this_partner @partner
		redirect_to [:admin, 'partner_home']
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
			Log.create(user_id: current_user.id, target_type: 2, target_id: @partner.id, action: 'create')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'partner', 'id' => @partner.id.to_s} })
			redirect_to admin_partner_path(@partner)
	    else
	    	flash[:error] = "L'entreprise n'a pas pu être créée."
	    	AppLogger.log ({'user_id' => @current_user, 'action' => 'created_fail', 'target_object' => {'type' => 'partner', 'id' => @partner.id.to_s} })
	    	render 'new'
	    end
	end
	def edit

	end
	def update
		store_logo

		if @partner.update_attributes(partner_params)
			update_logo(@partner)
			flash[:success] = "L'entreprise "+@partner.name+" a été modifiée avec succès."
			Log.create(user_id: current_user.id, target_type: 2, target_id: @partner.id, action: 'update')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'partner', 'id' => @partner.id.to_s} })
			redirect_to admin_partner_path(@partner)
		else
			flash[:error] = "L'entreprise n'a pas pu être modifiée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated_fail', 'target_object' => {'type' => 'partner', 'id' => @partner.id.to_s} })
			render 'edit'
		end
	end
	def destroy
	    if @partner.destroy
		    flash[:success] = "Entreprise partenaire supprimée."
		    Log.create(user_id: current_user.id, target_type: 2, target_id: @partner.id, action: 'destroy')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'destroyed', 'target_object' => {'type' => 'partner', 'id' => @partner.id.to_s} })
		    redirect_to admin_partners_path
		end
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

	        def check_privileges
		    	if userWeight <= User::Account_types[:admin][:weight]
		    		@partner = Partner.find_by(id: params[:id])
		    	else
		    		@partner = current_partner
		    	end
		    	
		    	if @partner.nil?
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
