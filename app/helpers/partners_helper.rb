module PartnersHelper
	def partners_for_select
	  Partner.all.collect { |o| [o.name, o.id] }
	end
end
