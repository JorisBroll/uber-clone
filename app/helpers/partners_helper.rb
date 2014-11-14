module PartnersHelper
	def partners_for_select(add_blank = false)
		@table = Partner.all.collect { |o| [o.name, o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end

	def get_logo(partner)
		if partner.logo
			return image_path('photos/'+partner.logo)
		else
			return image_path('photos/user.png')
		end
	end
end
