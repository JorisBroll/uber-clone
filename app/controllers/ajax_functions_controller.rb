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
				users = Partner.find_by(id: params['partners-drivers']).users.where('account_type = ? AND status = ?', User::account_types[:driver], User::statuses[params['partners-driver-status'].to_sym])
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

	def operator_steps_save_user
		rData = {}
		rData['status'] = true

		user = User.new(user_params)
		user.enabled = false
		user.password = 'default'
		user.account_type = 'client'
		if user.valid?
			user.save
			rData['user_created'] = {:id => user.id, :status => true }
		else
			rData['user_created'] = {:status => false, :errors => user.errors.full_messages}
			rData['status'] = false
		end

		rendering(rData)
	end
	def operator_steps_save_course
		rData = {}
		rData['status'] = true
		
		course = Course.new(course_params)
		course.stops = params['new_course_params']['stops'].to_json
		course.status = 'inactive'
		course.payment_by = params['attributions']['course']['payment_by']
		course.payment_when = params['attributions']['course']['payment_when']

		course.company_id = params['attributions']['course']['company_id']
		course.partner_id = params['attributions']['course']['partner_id']
		course.driver_id = params['attributions']['course']['driver_id']

		course.user_id = params['user_id']
		
		if course.valid?
			if course.company_id != '0'
				# MAIL + NOTIFICATION A L'ENTREPRISE
			end
			if course.partner_id != '0'
				# MAIL + NOTIFICATION A L'ENTREPRISE
			end
			if course.driver_id != '0'
				# MAIL + NOTIFICATION AU CHAUFFEUR
			end
			course.save
			rData['course_created'] = {:id => course.id, :status => true }
		else
			rData['course_created'] = {:status => false, :errors => user.errors.full_messages}
			rData['status'] = false
		end

		rendering(rData)
	end
		def user_params
	    	params['user']['new_user_params'].require(:user).permit(:name, :last_name, :email, :phone, :cellphone, :address, :postcode, :city, :enabled, :partner_id)
	    end

	    def course_params
	    	params['new_course_params'].require(:course).permit(:from, :to, :date_when, :time_when, :computed_distance, :computed_duration, :computed_price, :commission, :stops, :nb_people, :nb_luggage, :status, :notes, :created_by, :payment_when, :payment_by, :payment_status, :payment_type, :flight_number, :need_review)
	    end

		def rendering(rData)
			respond_to do |format|
				format.json { render :json => rData }
			end
		end
end