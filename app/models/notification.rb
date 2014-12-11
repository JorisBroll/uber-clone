class Notification < ActiveRecord::Base
	belongs_to :user, inverse_of: :notifications

	enum notif_type: [:canceling, :warning, :course, :user, :client]
	Notif_types = {
		'canceling' => {
			'name' => "Annulation",
			'icon' => "times-circle",
			'background' => "danger"
		},
		'warning' => {
			'name' => "Information",
			'icon' => "warning",
			'background' => "warning"
		},
		'course' => {
			'name' => "Course",
			'icon' => "flag-checkered",
			'background' => "success"
		},
		'user' => {
			'name' => "Utilisateur",
			'icon' => "user",
			'background' => "info"
		},
		'client' => {
			'name' => "Client",
			'icon' => "error",
			'background' => "info"
		}
	}

	def self.make(type, title, content, to, link)
		admins = partneradmins = []
    	if to.include?('admins')
		    admins = User.where('account_type = ?', 0)
	    end
	    if to.include?('partneradmins')
		    partneradmins = User.where('account_type = ?', 2)
	    end

	    recipients = admins.concat(partneradmins)

		recipients.each do |u|
		    @notification = u.notifications.build(notif_type: 1, title: title, content: content, link: link)
		    if @notification.valid? then @notification.save end
		end

		return recipients
    end
end
