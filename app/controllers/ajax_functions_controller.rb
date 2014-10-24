class AjaxFunctionsController < ApplicationController
	before_action :partneradmins_only

	include NotificationsHelper
	layout 'ajax'
	def get_pos
		@users = [User.find(34), User.find(36)]
		@users.each_with_index do |u, i|
			@users[i] = [u.pos_lat.to_f, u.pos_lon.to_f]
		end
		
		respond_to do |format|
			format.json { render :json => @users }
		end
	end
	def get_courses
		if (currently_admining_partner? || current_partner) && params['partner_id'] == 'current'
			@courses = current_partner.courses.where("status = ?", params['status'].to_i)
		elsif !params['partner_id'].nil? && params['partner_id'] != 'current'
			@courses = Partner.find_by(id: params['partner_id']).courses.where("status = ?", params['status'].to_i)
		else
			@courses = []
		end

		respond_to do |format|
			format.json { render :json => @courses }
		end
	end

	def notifications
		case params['notif_action']
		when 'set_seen'
			#@notification = Notification.find_by(id: params['id']).update({'seen' => true})
			@response = '1'
		when 'get'
			if params['id'] == 'all'
				@response = get_user_notifs.collect { |notif|
					{
						'id' => notif.id,
						'title' => notif.title,
						'content' => notif.content,
						'created_at' => notif.created_at.to_s,
						'icon' => Notification::Notif_types[notif.notif_type]['icon'],
						'background' => Notification::Notif_types[notif.notif_type]['background']
					}
				}
			else
				@response = Notification.find_by(id: params['id'])
			end
		else
			@response = '0'
		end

		respond_to do |format|
			format.json { render :json => @response }
		end
	end
end