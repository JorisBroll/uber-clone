module PromocodesHelper
	def promocodes_for_select(add_blank = false)
		@table = Promocode.all.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end
end
