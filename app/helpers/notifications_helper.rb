module NotificationsHelper
	def get_user_notifs(select = nil)
		@notifications = current_user.notifications.where("seen = false")
		if select
			@notifications = @notifications.select(select)
		end
		return @notifications
	end
end