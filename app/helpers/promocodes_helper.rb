module PromocodesHelper
	def promocodes_for_select(add_blank = false)
		@table = Promocode.all.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end

	def compute_price(course)
		return course.computed_price unless !course.promocode.nil?
		case course.promocode.effect_type
		when 'percent'
			return course.computed_price - course.computed_price*(course.promocode.effect_type_value.to_f/100)
		when 'fixed'
			return course.computed_price - course.promocode.effect_type_value
		end
	end
end
