module ApplicationHelper
	def build_address(object)
		if object.address.nil? then object.address = "Pas d'adresse" end
		if object.postcode.nil? then object.postcode = "Pas de code postal" end
		if object.city.nil? then object.city = "Pas de ville" end
		@address = object.address+', '+object.postcode+' - '+object.city
		return @address
	end
end
