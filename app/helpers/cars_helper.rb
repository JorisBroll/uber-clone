module CarsHelper
	def cars_for_select(add_blank = false)
		if current_partner.nil?
			@cars = Car.all
		else
			@cars = current_partner.cars
		end

		@table = @cars.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end
end
