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

	def getBalance(partner)
		courses = partner.courses
		naveco_collected = courses.where("status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_bies[:partner]).map {|s| price_afterPromo(s)}.reduce(0, :+)
		ttc = courses.where("status = ?", Course.statuses[:done]).map {|s| price_afterPromo(s, 'partner')}.reduce(0, :+)
		balance = ttc - naveco_collected
		return balance
	end
end
