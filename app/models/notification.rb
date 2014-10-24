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
end
