class PartnerAdmin::CarsController < ApplicationController
	before_action :partneradmins_only

  	def index
  		@cars = current_partner.cars
  	end
  	def show
  		@car = current_partner.cars.find_by(id: params[:car_id])
  	end
  	def new
		@car = current_partner.cars.build
	end
	def create
		@car = current_partner.cars.build(car_params)
		if @car.save
			flash[:success] = "La voiture "+@car.name+" a été crée."
			redirect_to partner_admin_cars_path(@partner)
	    else
	    	flash[:error] = "La voiture n'a pas pu être créée, veuillez réessayer :"
	    	render 'new'
	    end
	end
	def edit
		@car = get_correct_car
	end
	def update
		@car = get_correct_car
		if @car.update_attributes(car_params)
			flash[:success] = "La voiture "+@car.name+" a été modifiée avec succès."
			redirect_to partner_admin_cars_path
		else
			flash[:error] = "La voiture n'a pas pu être modifiée, veuillez réessayer :"
			render 'edit'
		end
	end
	def destroy
		@car = get_correct_car
		@car.destroy
		flash[:success] = "Voiture supprimée."
	    redirect_to partner_admin_cars_path
	end

		private

		    def car_params
		    	params.require(:car).permit(:name, :note, :slots)
		    end

		    def get_correct_car # Make sure we don't get an outside car
				if !current_partner.cars.find_by(id: params[:id]).nil?
					return current_partner.cars.find(params[:id])
				else
					flash[:error] = "Aucune voiture trouvé."
					redirect_to partner_admin_cars_path
				end
	        end

end
