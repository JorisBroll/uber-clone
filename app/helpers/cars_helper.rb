module CarsHelper
	def cars_for_select(partner = false)
	  Car.all.collect { |o| [o.name, o.id] }
	end
end
