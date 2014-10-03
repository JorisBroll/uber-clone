module CoursesHelper
	def getDateTime(course)
		if(!course.date_when.nil? && !course.time_when.nil?)
			'Le '+course.date_when.strftime("%d/%m/%Y")+' à '+course.time_when.strftime("%Hh%M")
		end
	end
end
