module CompaniesHelper
	def companies_for_select(add_blank = false, options = false)
		@companies = Company.all
		if options
			if options[:partner_id]
				@companies = Partner.find_by(id: options[:partner_id]).companies
			end
		end

		@table = @companies.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end
end