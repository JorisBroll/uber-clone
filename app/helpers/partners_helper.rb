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

	def getBalance(partner, before_date)
		courses = partner.courses
		collected_by_partner = courses.where("status = ? AND payment_by = ? AND date_when < ?", Course.statuses[:done], Course.payment_bies[:partner], before_date).map {|s| price_afterExtras(s)}.reduce(0, :+)
		ttc = courses.where("status = ? AND date_when < ?", Course.statuses[:done], before_date).map {|s| price_afterExtras(s, 'partner')}.reduce(0, :+)
		balance = ttc - collected_by_partner

		payments = Payment.where("to_type = 'partner' AND to_id = ? AND created_at < ?", partner.id, before_date).map {|p| p.amount}.reduce(0, :+)

		balance -= payments

		return balance
	end
end
