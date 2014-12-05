class AjaxFunctionsController < ApplicationController
	before_action :partneradmins_only

	include NotificationsHelper
	layout 'ajax'
	def map_get
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

	def get_objects
		rData = {}

		if !params['objects'].nil?
			select_array = [:id, :name]
			if params['objects'] == 'users'
				select_array.push(:last_name)
			end
			rData = params['objects'].classify.constantize.all.select(select_array)
			
		end
		
		rendering(rData)
	end

	def get_drivers
		if !params['options'].nil?
			options = params['options']
			if !options['partner_id'].nil?
				users = Partner.find_by(id: options['partner_id']).users
			else
				users = User.all
			end
		else
			users = User.all
		end
		
		rData = users.where('account_type = ? OR account_type = ?', User.account_types[:driver], User.account_types[:partneradmin]).select([:id, :name])

		rendering(rData)
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

		rendering(@response)
	end

	def operator_steps_save
		rData = {}

		params['password'] = params[':password_confirmation'] = nil
		params['enabled'] = false

		if params['user']['is_new_user']
			user = User.new(user_params)
			rData['spect'] = user.inspect
			#if user.save!
			#	rData['jack'] = "yo"
			#end
		end


		rendering(rData)
	end
		def user_params
	    	params['user'].require(:new_user_params).permit(:name, :last_name, :email, :phone, :cellphone, :photo, :address, :postcode, :city, :password, :password_confirmation, :enabled)
	    end

		def rendering(rData)
			respond_to do |format|
				format.json { render :json => rData }
			end
		end
end