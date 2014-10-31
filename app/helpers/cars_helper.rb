module CarsHelper
	def cars_for_select(add_blank = false, options = false)
		@cars = Car.all
		if options
			if options[:partner_id]
				@cars = Partner.find_by(id: options[:partner_id]).cars
			end
		end

		@table = @cars.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end
end
