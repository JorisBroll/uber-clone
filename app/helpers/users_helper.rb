module UsersHelper
	def users_for_select(add_blank = false, options = false)
		@users = User.all
		if options
			if options[:partner_id]
				@users = Partner.find_by(id: options[:partner_id]).users
			end
		end

	  	@table = @users.collect { |o| [build_name(o), o.id] }
		if add_blank
			@table.unshift([add_blank, 0])
		end
		return @table
	end

	def drivers_for_select
	  User.where("account_type = ?", User.account_types[:driver]).collect { |o| [o.name, o.id] }
	end

	def build_name(user, with_id = false)
		@name = user.name
		@name += ' '+user.last_name unless user.last_name.nil?
		@name = user.id.to_s+'/'+@name unless !with_id
		return @name
	end

	def get_photo(user)
		if user.photo
			return image_path('photos/'+user.photo)
		else
			return image_path('photos/user.png')
		end
	end
end
