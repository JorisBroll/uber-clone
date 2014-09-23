class CarsController < ApplicationController
  def index
  	@cars = Car.find_by(id_partner: 1)
  end
end
