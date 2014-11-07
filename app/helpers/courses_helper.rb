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

	def price_afterPromo(course, toNaveco = false, toPartner = false)
		return course.computed_price unless !course.promocode.nil?
		case course.promocode.effect_type
		when 'percent'
			price = course.computed_price - course.computed_price*(course.promocode.effect_type_value.to_f/100)
		when 'fixed'
			price = course.computed_price - course.promocode.effect_type_value
		end

		if toNaveco
			shareToPartner = (course.computed_price*((100-course.commission.to_f)/100))
			price = course.computed_price - shareToPartner
		end
		if toPartner
			price = (course.computed_price*((100-course.commission.to_f)/100))
		end
		return price
	end
end
