module CoursesHelper
	def getDateTime(course)
		if(!course.date_when.nil? && !course.time_when.nil?)
			'Le '+course.date_when.strftime("%d/%m/%Y")+' à '+course.time_when.strftime("%Hh%M")
		end
	end

	def getTripDuration(course)
		duration = ((course.trip_finished - course.trip_started).to_i)/60
		return duration
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

	def price_afterExtras(course, to = false)
		price = course.computed_price

		price -= course.promocode_amount unless course.promocode_amount.nil?

		price += course.stops_price unless course.stops_price.nil?
		price += course.damage_price unless course.damage_price.nil?

		case to
			when 'naveco'
				shareToPartner = (course.computed_price*((100-course.commission.to_f)/100))
				price = price - shareToPartner
			when 'partner'
				price = (course.computed_price*((100-course.commission.to_f)/100))
		end
		return price
	end

	def checkPromo(course)
		if !course.user.nil? && !course.promocode.nil?
			user = course.user
			promocode = course.promocode

			isValid = false
			case promocode.effect_length
			when 'days'
				dates = {}
				dates[:promocode_start] = promocode.created_at
				dates[:promocode_end] = dates[:promocode_start] + promocode.effect_length_value.days
				dates[:course_created] = course.created_at || Time.now

				if dates[:promocode_start] < dates[:promocode_end] && dates[:course_created] > dates[:promocode_start] && dates[:course_created] < dates[:promocode_end]
					isValid = true
				end

			when 'uses'
				nb_course_with_promocode = user.courses.where('promocode_id = ? AND status != ?', promocode.id, Course.statuses[:canceled]).count

				if nb_course_with_promocode <= promocode.effect_length_value
					isValid = true
				end
			
			when 'once_every_x'
				nb_course_with_promocode = user.courses.where('promocode_id = ? AND status != ? AND created_at < ?', promocode.id, Course.statuses[:canceled], dates[:course_created]).count
				
				if (nb_course_with_promocode+1) % promocode.effect_length_value == 0
					isValid = true
				end
			end

			if isValid
				case course.promocode.effect_type
				when 'percent'
					price = course.computed_price*(course.promocode.effect_type_value.to_f/100)
				when 'fixed'
					price = course.promocode.effect_type_value
				end
			else
				price = 0
			end

			return price
		else
			return 0
		end
	end
end
