module CompaniesHelper
	def companies_for_select(add_blank = false)
		if current_partner.nil?
			@companies = Company.all
		else
			@companies = current_partner.companies
		end

		@table = @companies.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end
end