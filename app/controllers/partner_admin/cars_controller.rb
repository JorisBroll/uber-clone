class PartnerAdmin::CarsController < ApplicationController
  	def index
  		@cars = Partner.find(params[:partner_id]).cars
  		#@car = Car.new
  	end
  	def show
  		@cars = current_user.partner.cars.find(params[:car_id])
  		#@car = Car.new
  	end
  	def new
  		@partner = Partner.find(params[:partner_id])
		@car = @partner.cars.build
	end
	def create
		@partner = Partner.find(params[:partner_id])
		@car = @partner.cars.build(car_params)
		if @car.save
			flash[:success] = "La voiture "+@car.name+" a été crée."
			redirect_to partner_path(@partner)
	    else
	    	flash[:error] = "La voiture n'a pas pu être créée, veuillez réessayer :"
	    	redirect_to new_partner_car_path
	    end
	end
	def edit
		@car = Car.find(params[:id])
	end
	def update
		@car = Car.find(params[:id])
		@partner = @car.partner
		if @car.update_attributes(car_params)
			flash[:success] = "La voiture "+@car.name+" a été modifiée avec succès."
			redirect_to partner_path(@partner)
		else
			flash[:error] = "La voiture n'a pas pu être modifiée, veuillez réessayer :"
			redirect_to edit_car_path(params[:id])
		end
	end

		private

		    def car_params
		    	params.require(:car).permit(:name, :note, :slots)
		    end
end
