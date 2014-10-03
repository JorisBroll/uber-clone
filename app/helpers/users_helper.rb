module UsersHelper
	def users_for_select(partner = false)
	  User.all.collect { |o| [o.name, o.id] }
	end
	def drivers_for_select
	  User.where("account_type = ?", User.account_types[:driver]).collect { |o| [o.name, o.id] }
	end
end
