class AjaxFunctionsController < ApplicationController
	before_action :partneradmins_only

	include NotificationsHelper
	layout 'ajax'
	def get
		rData = {}

		if !params['courses-view'].nil? && to_bool(params['courses-view'])
			if (currently_admining_partner? || current_partner) && params['courses-partner'] == 'current'
				rData[:courses] = current_partner.courses.where("status = ?", params['courses-status'].to_i)
			elsif !params['courses-partner'].nil? && params['courses-partner'] != 'current'
				rData[:courses] = Partner.find_by(id: params['courses-partner']).courses.where("status = ?", params['courses-status'].to_i)
			else
				rData[:courses] = []
			end
		end
		

		if !params['partners-view'].nil? && to_bool(params['partners-view'])
			if params['partners-drivers'] == 'all'
				users = User.where('account_type = ? AND status = ?', User::account_types[:driver], 0) # All online drivers
			elsif !params['partners-drivers'].nil? && params['courses-partner'] != 'all'
				users = Partner.find_by(id: params['partners-drivers']).users.where('account_type = ? AND status = ?', User::account_types[:driver], params['partners-driver-status'].to_i)
			end
				#users = users.to_json(:include => :partner)
				rData[:users] = users
			end

		respond_to do |format|
			format.json { render :json => rData.to_json(:include => { :partner => { :only => :name } }) }
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