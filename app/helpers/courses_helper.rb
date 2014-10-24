module CoursesHelper
	def getDateTime(course)
		if(!course.date_when.nil? && !course.time_when.nil?)
			'Le '+course.date_when.strftime("%d/%m/%Y")+' à '+course.time_when.strftime("%Hh%M")
		end
	end

	def payment_when_for_select(add_blank = false)
		@table = Course::Payment_whens.collect { |i, o| [o['name'], i] }
	end
end
