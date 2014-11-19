module CoursesHelper
	def getDateTime(course)
		if(!course.date_when.nil? && !course.time_when.nil?)
			'Le '+course.date_when.strftime("%d/%m/%Y")+' à '+course.time_when.strftime("%Hh%M")
		end
	end

	def payment_status_for_select
		@table = Course::Payment_status.collect { |i, o| [o[:name], i] }
	end

	def payment_when_for_select
		@table = Course::Payment_whens.collect { |i, o| [o[:name], i] }
	end

	def payment_by_admin_for_select
		@table = Course::Payment_by.collect { |i, o| [o[:name_admin], i] }
	end

	def payment_by_partner_for_select
		@table = Course::Payment_by.collect { |i, o| [o[:name_partneradmin], i] }
	end

	def price_afterPromo(course, to = false)
		price = course.computed_price

		if !course.promocode.nil?
			case course.promocode.effect_type
			when 'percent'
				price = course.computed_price - course.computed_price*(course.promocode.effect_type_value.to_f/100)
			when 'fixed'
				price = course.computed_price - course.promocode.effect_type_value
			end
		end

		case to
			when 'naveco'
				shareToPartner = (course.computed_price*((100-course.commission.to_f)/100))
				price = course.computed_price - shareToPartner
			when 'partner'
				price = (course.computed_price*((100-course.commission.to_f)/100))
		end
		return price
	end
end
