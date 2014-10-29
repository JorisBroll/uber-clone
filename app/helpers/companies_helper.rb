module CompaniesHelper
	def companies_for_select(add_blank = false)
		@table = Company.all.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end
end