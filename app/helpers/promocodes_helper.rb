module PromocodesHelper
	def promocodes_for_select(add_blank = false)
		@table = Promocode.all.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end

	def compute_price(promocode, price)
		case promocode.effect_type
		when 'percent'
			return price - price*(promocode.effect_type_value.to_f/100)
		when 'fixed'
			return price - promocode.effect_type_value
		end
	end
end
