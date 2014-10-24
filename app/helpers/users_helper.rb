module UsersHelper
	def users_for_select(add_blank = false)
	  	@table = User.all.collect { |o| [build_name(o), o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end

	def drivers_for_select
	  User.where("account_type = ?", User.account_types[:driver]).collect { |o| [o.name, o.id] }
	end

	def build_name(user)
		@name = user.name
		@name += ' '+user.last_name unless user.last_name.nil?
		return @name
	end
end
