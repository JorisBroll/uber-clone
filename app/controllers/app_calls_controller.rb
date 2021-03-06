class AppCallsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :check_code
	before_action :validate_token, :except => [:signup, :login, :fb_signup_login, :activate_code, :reset_password, :new_password]
	before_action :validate_account_type, :except => [:signup, :login, :fb_signup_login, :activate_code, :reset_password, :new_password]

	require 'openssl'

	####### BOTH APPS ###########


		####### Login/Signup ###########

		def signup # Call to make new users
			rData = {}

			user = User.new(user_params)
			user.enabled = false
			user.account_type = 'client'
			user.activation_code = (0...5).map { ('A'..'Z').to_a[rand(26)] }.join
			if user.save
				send_sms(user.cellphone, "Naveco : Merci de votre inscription, voici votre code d'activation : #{user.activation_code}")
				rData[:user_created] = {:status => true, :activation_code => user.activation_code, :id => user.id}
			else
				rData[:user_created] = {:status => false, :errors => user.errors.full_messages}
				user.destroy
				rData[:status] = false
			end

			rData[:debug] = user

			rendering(rData)
		end

		def activate_code # Call to validate user accounts with the code provided via SMS in #signup
			user = User.find_by(id: params['activation']['user_id'])
			
			if user.activation_code == params['activation']['activation_code'].upcase
				user.update(enabled: true)
				rData = {:status => true}
			else
				rData = {:status => false, :errors => ['Le code ne correspond pas.']}
			end

			rendering(rData)
		end

		def login # Call to log into the app
			user = User.find_by(email: params['credentials']['email'].downcase).try(:authenticate, Base64.decode64(params['credentials']['password']))

			if user && !user.enabled
				rData = {:status => false, :errorMessage => 'Utilisateur non activé. Veuillez contacter Naveco pour résoudre le problème.' }
			elsif user
				user_data = {
					:name => user.name,
					:last_name => user.last_name,
					:photo => user.photo_url
				}
				uncrypted_token = {:user_id => user.id.to_s, :deliver_date => Time.zone.now}
				if params['credentials']['account_type'] == 'driver' && ['driver', 'partneradmin', 'admin', 'superadmin'].include?(user.account_type)
					uncrypted_token[:account_type] = 'driver'
					user.status = 'ready'
				else
					uncrypted_token[:account_type] = 'client'
				end

				token = crypt_token(uncrypted_token.to_json)
				#token = uncrypted_token.to_json
				
				user.login_token = token
				if user.save
					rData = {:status => true, :loginData => {:token => token, :user_data => user_data} }
				end
			else
				rData = {:status => false, :errorMessage => 'Impossible de se connecter. Veuillez vérifier votre email/password.' }
			end
			
			rendering(rData)
		end

		def fb_signup_login
			rData = {}

			if(!params['user']['facebookID'].nil? && params['user']['facebookID'] != "")
				user = User.find_by(facebookID: params['user']['facebookID'])
			end

			if !user.nil?
				user_data = {
					:name => user.name,
					:last_name => user.last_name,
					:photo => user.photo_url
				}
				uncrypted_token = {:user_id => user.id.to_s, :deliver_date => Time.zone.now, :account_type => 'client'}.to_json
				token = crypt_token(uncrypted_token)
				
				user.update(login_token: token)
				rData = {:status => true, :loginData => {:token => token, :user_data => user_data} }
			else
				params['user']['password'] = 'NobodyGivesAShit'+(0...50).map { ('0'..'Z').to_a[rand(26)] }.join
				params['user']['password_confirmation'] = params['user']['password']

				user = User.new(user_params)
				user.enabled = false
				user.account_type = 'client'

				if user.save
					user_data = {
						:name => user.name,
						:last_name => user.last_name,
						:photo => user.photo_url
					}

					uncrypted_token = {:user_id => user.id.to_s, :deliver_date => Time.zone.now, :account_type => 'client'}.to_json
					token = crypt_token(uncrypted_token)
					user.update(login_token: token)

					rData = {:status => true, :loginData => {:token => token, :user_data => user_data} }
				else
					#user.destroy
					rData = {:status => false, :errors => user.errors.full_messages}
				end
			end
			

			rendering(rData)
		end

		def logout
			@user.login_token = nil
			if @account_type == "driver"
				if !@user.car.nil?
					@user.car = nil
				end
			end
			@user.status = 'offline'
			@user.save
			rendering({})
		end

		def update_photo
			rData = {}

			@user.photo = params['photo']

			if @user.save
				Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'update_photo');
				rData[:status] = true
			else
				Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'fail_update_photo');
				rData = {
					:status => false,
					:errorMessage => ''
				}
			end
			
			rendering(rData)
		end

		def update_password
			rData = {}

			if @user.try(:authenticate, params['passwords']['old-password'])
				if params['passwords']['new-password'] == params['passwords']['new-password2']
					@user.password = params['passwords']['new-password']
					if @user.valid?
						rData[:status] = true
					else
						rData[:status] = false
						rData[:message] = "Mot de passe invalide."
					end
				else
					rData[:status] = false
					rData[:message] = "Les deux mots de passe ne correspondent pas."
				end
			else
				rData[:status] = false
				rData[:message] = "Mot de passe érroné."
			end
			rendering(rData)
		end

		def reset_password
			rData = {}

			user = User.find_by(email: params['email'].downcase);
			if !user.nil?
				user.activation_code = (0...6).map { ('A'..'Z').to_a[rand(26)] }.join
				user.save
				UserMailer.custom_email(user.email, "Votre code de réinitialisation", "Bonjour, voici votre code nécéssaire à la réinitialisation de votre mot de passe : #{user.activation_code}".html_safe).deliver
				rData[:status] = true
			else
				rData[:status] = false
				rData[:message] = "L'utilisateur n'existe pas."
			end

			rendering(rData)
		end

		def new_password
			rData = {}

			user = User.find_by(email: params['email'].downcase);
			if !user.nil?
				if user.activation_code == params['code']
					user.password = params['password']
					if user.valid?
						rData[:status] = true
					else
						rData[:status] = false
						rData[:message] = "Nouveau mot de passe invalide."
					end
				else
					rData[:status] = false
					rData[:message] = "Code de sécurité eronné."
				end
			else
				rData[:status] = false
				rData[:message] = "L'utilisateur n'existe pas."
			end

			rendering(rData)
		end

		def course_report
			rData = {}

			course = Course.find_by(id: params['course_id'])
			type_user = ""
			sentence = ""

			if !course.nil?
				if @account_type == 'driver'
					type_user = 'Le chauffeur'
				elsif @account_type == 'client'
					type_user = 'Le client'
				end
				sentence = "#{type_user} ##{@user.id}/#{@user.full_name} a signalé la course numéro n°#{course.id}"

				UserMailer.custom_backoffice_email('joris.broll@gmail.com', "Course signalée : n°#{course.id}", sentence.html_safe).deliver
				rData[:status] = true;
			end

			rendering(rData)
		end

		####### Courses REST ###########
		def courses_index
			rData = {}

			if @account_type == "driver"
				rData[:courses] = @user.drives_courses.where('status = ? OR status = ?', Course.statuses[:inactive], Course.statuses[:in_progress]).order(date_when: :desc, time_when: :desc).select(:id, :from, :to, :status, :course_type, :date_when, :time_when, :trip_wait_start, :trip_started, :trip_finished, :behavior_feedback, :user_id, :stops, :final_price, :created_at)
				rendering(rData, {:user => {:only => [:id, :name, :last_name, :cellphone, :email, :photo_url], :methods => [:photo_url] }}, nil, [:date_when_s, :time_when_s, :trip_wait_start_sec, :trip_started_sec, :trip_finished_sec])
			elsif @account_type == "client"
				rData[:courses] = {
					:incoming => @user.courses.where('status = ? OR status = ?', Course.statuses[:inactive], Course.statuses[:in_progress]).order(date_when: :desc, time_when: :desc).select(:id, :from, :to, :date_when, :time_when, :user_id, :created_at),
					:done => @user.courses.where('status = ?', Course.statuses[:done]).order(date_when: :desc, time_when: :desc).select(:id, :from, :to, :date_when, :time_when, :user_id, :created_at)
				}
				rendering(rData, nil, nil, [:date_when_s, :time_when_s])
			end
		end

		def course_try_cancel
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course
				rData[:status] = true
				rData[:course_id] = course.id

				if course.course_type == 'now'
					if course.created_at <= Time.zone.now-(8*60) # If canceled 8 mins after booking
						rData[:cancel_status] = false
						if course.car_type == 'berline'
							rData[:price] = 8
						elsif course.car_type == 'van'
							rData[:price] = 10
						end
					else
						rData[:cancel_status] = true
					end

					#rData[:debug] = {
					#	:created_at => course.created_at,
					#	:now => Time.zone.now,
					#	:eightminsago => Time.zone.now-(8*60)
					#}
				elsif course.course_type == 'later'
					if !course.date_when.nil? && !course.time_when.nil?
						course_datetime = Time.zone.local(course.date_when.year, course.date_when.month, course.date_when.day, course.time_when.hour, course.time_when.min, course.time_when.sec)

						diff = (course_datetime - Time.zone.now).round

						rData[:debug] = {
							:diff => diff,
							:course_datetime => course_datetime,
							:now => DateTime.now,
							:limit => course_datetime-(30*60)
						}

						if diff <= 1800 # If canceled 30 mins before the start
							rData[:cancel_status] = false

							if diff < 0 then diff = 0 end
							price_diff = (1800 - diff)/60

							if course.car_type == 'berline'
								rData[:price] = 13
								rData[:price] = 0.45*price_diff
							elsif course.car_type == 'van'
								rData[:price] = 15
								rData[:price] = 0.5*price_diff
							end

							rData[:price] = rData[:price].round(2)

						else
							rData[:cancel_status] = true
						end
					else
						rData[:cancel_status] = true
					end
				end
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def course_cancel
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course
				course.status = Course.statuses[:canceled]
				course.cancel_reason = params['cancel_reason']
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'cancel');
					rData = {
						:status => true
					}
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_cancel');
					rData = {
						:status => false,
						:errorMessage => ''
					}
				end
			else
				rData[:status] = false
				rData[:errorMessage] = 'Paramètres incorrects'
			end

			rendering(rData)
		end

	####### CLIENT APP ###########

		####### Courses REST ###########
		def course_create
			rData = {}

			course = @user.courses.build(course_params)

			if course.save
				Log.create(user_id: @user.id, target_type: 1, target_id: @user.id, action: 'create');
				rData = {
					:status => true,
					:course_id => course.id
				}
			else
				Log.create(user_id: @user.id, target_type: 1, target_id: @user.id, action: 'fail_create');
				rData = {
					:status => false
				}
				course.destroy
			end

			rendering(rData)
		end

		def course_check_driver
			rData = {}

			course = @user.courses.find_by(id: params['course_id'])

			if !course.nil?

				rData[:status] = true
				rData[:course_id] = course.id
				if !course.driver_id.nil?
					driver = User.find_by(id: course.driver_id)
					if !driver.pos_lat.nil?
						driver.pos_distance = distance_between(@user.pos_lat, @user.pos_lon, driver.pos_lat, driver.pos_lon)
						driver.pos_time = convert_distance_to_time(driver.pos_distance)
					else
						driver.pos_distance = 1000
						driver.pos_time = 1000
					end

					rData[:driver] = driver
					rData[:driver_photo] = driver.photo_url
					rData[:driver_status] = true
				else
					rData[:driver_status] = false
				end
			else
				rData = {
					:status => false
				}
			end

			rendering(rData, nil, nil, [:car, :pos_time])
		end

		def course_refresh_status
			rData = {}

			course = @user.courses.find_by(id: params['course_id'])

			if !course.nil?

				rData[:status] = true

				rData[:course] = course

				if !course.driver_id.nil?
					driver = User.find_by(id: course.driver_id)
					rData[:driver] = driver
					rData[:driver_photo] = driver.photo_url
					rData[:driver_status] = true
				else
					rData[:driver_status] = false
				end
			else
				rData = {
					:status => false
				}
			end

			rendering(rData)
		end

		def get_drivers_location
			rData = {}

			if !params['marker_pos_lat'].nil? && !params['marker_pos_lng'].nil?

				drivers = User.where("account_type <= 4 AND status = 0").select(:id, :pos_lat, :pos_lon, :pos_deg)
				rData[:drivers_pos] = {}

				if !drivers.nil?
					rData[:status] = true
					drivers.each do |driver|
						if !driver.pos_lat.nil?
							driver.pos_distance = distance_between(params['marker_pos_lat'].to_f, params['marker_pos_lng'].to_f, driver.pos_lat, driver.pos_lon)
							driver.pos_time = convert_distance_to_time(driver.pos_distance)

							driver.mpos_latLng = {
								lat:driver.pos_lat,
								lng:driver.pos_lon
							}
							driver.mpos_deg = rand(0..360)

							if driver.pos_distance < 20 then rData[:drivers_pos][driver.id] = driver end
						end
					end
				end
			end

			#rData[:debug] = params

			rendering(rData, nil, nil, [:mpos_latLng, :mpos_deg, :pos_latLng, :pos_time, :pos_distance])
		end

		def client_send_feedback_and_pay
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course
				rData[:status] = true
				course.trip_feedback = params['feedback_value']
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'feedback');
					rData[:status_feedback] = true
					course.update(status: Course::statuses[:done])
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_feedback');
					rData[:status_feedback] = false
					rData[:errorMessage] = "Le feedback du client concernant le chauffeur n'a pas été enregistré."
				end
			else
				rData[:status] = false
				rData[:errorMessage] = 'Paramètres incorrects'
			end

			rendering(rData)
		end

		# def test_pay
		#  	customer = Braintree::Customer.find(@user.id)

		#  	result = Braintree::Transaction.sale(
		#  	    :payment_method_token => customer.credit_cards[0].token,
		#  	    :amount => "0.01"
		#  	)

		#  	if result.success?
		#  		rData = true
		#  	else
		#  		rData = false
		#  	end

		#  	rendering(rData)
		# end

		####### User REST ###########
		def update_user
			@user.name = params['user_infos']['name']
			@user.last_name = params['user_infos']['last_name']
			@user.email = params['user_infos']['email']
			@user.cellphone = params['user_infos']['cellphone']

			if @user.valid?
				@user.save
				rData = { :status => true }
			else
				rData = { :status => false, :errors => @user.errors.full_messages }
			end

			rendering(rData)
		end
		def update_user_location
			@user.pos_lat = params['user_lat']
			@user.pos_lon = params['user_lon']

			if @user.valid?
				@user.save
				rData = { :status => true }
			else
				rData = { :status => false }
			end

			rendering(rData)
		end

		####### Payment Infos REST ###########
		def get_braintree_user_token
			rData = {}

			begin
				customer = Braintree::Customer.find(@user.id)
			rescue Braintree::NotFoundError # If the Braintree user does not yet exist.
				customer = Braintree::Customer.create(
					:id => @user.id,
					:first_name => @user.name,
					:last_name => @user.last_name
				)
			end

			payment_methods = customer.credit_cards.count + customer.paypal_accounts.count

			if @client_token = Braintree::ClientToken.generate(:customer_id => @user.id)
				rData[:client_token] = @client_token
				rData[:methods] = payment_methods
				rData[:status] = true
			else
				rData[:status] = false
			end

			rendering(rData)
		end

		def get_braintree_user_methods
			rData = {}

			begin
				customer = Braintree::Customer.find(@user.id)
			rescue Braintree::NotFoundError # If the Braintree user does not yet exist.
				customer = Braintree::Customer.create(
					:id => @user.id,
					:first_name => @user.name,
					:last_name => @user.last_name
				)
			end
			rData[:methods_list] = []
			customer.paypal_accounts.each do |paypal_account|
				#Braintree::PaymentMethod.delete(paypal_account.token)
				rData[:methods_list] << {:token => paypal_account.token, :name => paypal_account.email}
			end
			customer.credit_cards.each do |credit_card|
				#Braintree::PaymentMethod.delete(credit_card.token)
				rData[:methods_list] << {:token => credit_card.token, :name => "Carte bancaire (**** **** **** #{credit_card.last_4})"}
			end

			rData[:debug] = customer.paypal_accounts[0].inspect

			rendering(rData)
		end

		####### Promocodes REST ###########
		def promocodes_index
			rData = {}

			promocodes = @user.promocodes

			if !promocodes.nil?
				rData[:codes] = promocodes
				if !@user.selected_promocode.nil?
					rData[:codes].each do |code|
						if code.id == @user.selected_promocode
							code.selected = true
						end
					end
				end
			end

			rendering(rData, nil, nil, [:effect_type_s, :effect_length_s, :selected])
		end

		def promocode_attach
			rData = {}

			if !params['promocode'].nil?
				rData[:status] = true
				promocode = Promocode.find_by(code: params['promocode'])
				if promocode.nil?
					rData[:add_status] = false;
					rData[:message] = "Ce code n'existe pas."
				else
					rData[:add_status] = true;
					user_promocode = @user.promocodes.find_by(code: params['promocode'])
					if user_promocode
						rData[:add_status] = false;
						rData[:message] = "Ce code est déjà enregistré."
					else
						rData[:add_status] = true;
						@user.promocodes << promocode
					end
				end
			else
				rData[:status] = false
			end
			
			rendering(rData)
		end

		def promocode_select
			rData = {}

			promocode = Promocode.find_by(id: params['promocode_id'])
			if promocode.nil?
				rData[:status] = false
				rData[:message] = "Ce code n'existe pas."
			else
				@user.selected_promocode = promocode.id
				@user.save
				rData[:status] = true
				rData[:promocode_id] = promocode.id
			end
			
			rendering(rData)
		end


	####### DRIVER APP ###########

		####### User REST ###########
		def profile_index
			rData = @user

			rendering(rData, nil, [:id, :name, :last_name, :cellphone, :email], [:photo_url])
		end

		def update_status
			rData = {}

			@user.status = params['status']

			if @user.save
				Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'update_status');
				rData = {
					:status => true,
					:new_user_status => @user.status
				}
			else
				Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'fail_update_status');
				rData = {
					:status => false,
					:errorMessage => ''
				}
			end

			rendering(rData)
		end

		def update_cellphone
			rData = {}

			@user.cellphone = params['number']

			if @user.save
				Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'update_cellphone');
				rData = {
					:status => true
				}
			else
				Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'fail_update_cellphone');
				rData = {
					:status => false,
					:errorMessage => ''
				}
			end
			
			rendering(rData)
		end

		####### Cars REST ###########
		def cars_index
			rData = {}

			if !@user.partner.nil?
				cars = @user.partner.cars

				thisMorning = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 8, 0, 0)

				cars.each do |car|
					if !car.last_selected.nil? && car.last_selected < thisMorning
						car.update(driven_by: nil)
					end
				end

				rData[:cars] = @user.partner.cars
			end

			rData[:status] = false

			rendering(rData)
		end

		def select_car
			rData = {}

			car = Car.find_by(id: params['car_id'])

			if car
				Car.where('driven_by = ?', @user.id).update_all(driven_by: nil)
				car.driven_by = @user.id
				if car.save
					Log.create(user_id: @user.id, target_type: 8, target_id: car.id, action: 'select');
					rData = {
						:status => true
					}
				else
					Log.create(user_id: @user.id, target_type: 8, target_id: car.id, action: 'fail_select');
					rData = {
						:status => false,
						:errorMessage => ''
					}
				end
			else
				rData = {
					:status => false,
					:errorMessage => ''
				}
			end


			rendering(rData)
		end

		####### Courses REST ###########
		def courses_query_new
			# @user => Current user of the driver app looking form new courses to take
			# 

			rData = {}
			rData[:debug] = {}

			rData[:course] = nil

			# Look for courses that :
			# - Have no assigned driver
			# - Aren't from before this morning
			courses = Course.where('driver_id IS NULL AND status = ? AND date_when >= ?', Course::statuses[:inactive], Time.now.beginning_of_day).order(id: :desc)
			rData[:debug][:courses] = courses
			#rData[:debug][:courses_a] = Course.where('driver_id IS NULL')
			#rData[:debug][:courses_b] = Course.where('status = ?', Course::statuses[:inactive])
			#rData[:debug][:courses_c] = Course.where('date_when >= ?', Time.now.beginning_of_day)

			# Look for users that :
			# - Are not clients (everyone other account_type can use the driver app)
			# - Are 'ready'
			drivers = User.where("account_type != ? AND status = ?", User.account_types[:client], User.statuses[:ready])
			rData[:debug][:drivers] = drivers
			
			# The shortest distance from driver to course client, we start with a big value because fuck checking for nil
			distanceMin = 1000

			# We loop for each course that is possible to take and check :
			# 1) If the @user has not already rejected this course
			# 2) If the @user is actually the closest driver from the client
			closest_driver = nil

			courses.each do |course|
				rData[:debug][:last_looped_course] = course
				rData[:debug][:last_looped_user] = course.user

				# 1)
				if course.rejected_by.nil? || !course.rejected_by.include?(@user.id)

					# 2)
					drivers.each do |driver|
						driver.pos_distance = distance_between(driver.pos_lat, driver.pos_lon, course.user.pos_lat, course.user.pos_lon)
						if driver.pos_distance != 0 && driver.pos_distance < distanceMin
							if course.rejected_by.nil? || !course.rejected_by.include?(driver.id)
								closest_driver = driver.id
								distanceMin = driver.pos_distance
							end
						end
					end
					rData[:debug][:drivers] = drivers

					if !closest_driver.nil? && closest_driver == @user.id
						rData[:course] = course
					end
				end
			end

			rData[:status] = true
			rData[:distance] = distanceMin
			rData[:driver] = closest_driver

			rendering(rData, nil, nil, [:photo_url, :pos_distance])
		end

		def course_accept
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course && course.driver_id.nil?
				course.driver_id = @user.id
				course.status = 2 # In progress
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'accept_course');
					rData = {
						:status => true
					}
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_accept_course');
					rData = {
						:status => false,
						:errorMessage => "Erreur lors le l'acceptation de la course"
					}
				end
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def course_decline
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course
				if course.rejected_by != nil
					if !course.rejected_by.include? @user.id then course.rejected_by = course.rejected_by+[@user.id] end
				else
					course.rejected_by = [@user.id]
				end

				#course.rejected_by = [8]
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'decline_course');
					rData = course.rejected_by
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_decline_course');
					rData = {
						:status => false,
						:errorMessage => "Erreur lors le l'acceptation de la course"
					}
				end
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def course_check_canceled
			rData = {}

			course = @user.drives_courses.find_by(id: params['course_id'])

			if !course.nil? && course.status == 'canceled'
				rData[:status] = true
			else
				rData[:status] = false
			end

			#rData[:debug] = course

			rendering(rData)
		end

		def incoming_sms
			course = Course.find_by(id: params['course_id'])

			if course
				#send_sms(course.user.cellphone, "Naveco : Course [##{course.id}] : Votre chauffeur est en route !")
				rData = {:status => true}
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def start_sms
			course = Course.find_by(id: params['course_id'])

			if course
				#send_sms(course.user.cellphone, "Naveco : Course [##{course.id}] : Votre chauffeur est arrivé au point de départ.")
				course.trip_wait_start = Time.now
				course.save
				rData = {:status => true}
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def start_trip
			course = Course.find_by(id: params['course_id'])

			if course
				course.trip_started = Time.now				
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'start');
					rData = {
						:status => true
					}
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_start');
					rData = {
						:status => false,
						:errorMessage => "La date de départ de la course n'a pas été enregistrée."
					}
				end
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def end_trip
			rData = {}
			course = Course.find_by(id: params['course_id'])

			if course
				course.trip_finished = Time.now
				course.stops_price = params['stops_price']
				course.final_price = course.computed_price + course.stops_price
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'end');
					rData[:status] = true
					rData[:course] = course
					rData[:user] = User.find_by(id: course.user_id)
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_end');
					rData[:status] = false
					rData[:errorMessage] = "La date de départ de la course n'a pas été enregistrée."
				end
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData, nil, nil, [:photo_url])
		end

		def driver_send_feedback
			course = Course.find_by(id: params['course_id'])

			if course
				course.behavior_feedback = params['feedback_value']
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'feedback');
					rData = {
						:status => true
					}
					course.update(status: Course::statuses[:done])

					payment = Braintree::Transaction.sale(
					    :payment_method_token => params['payment_method_token'],
					    :amount => course.final_price
					)

					if payment.success?
						rData[:status_payment] = true
						rData[:debug] = {
							:payment_method_token => params['payment_method_token'],
					  		:amount => course.final_price
						}
					else
						rData[:status_payment] = false
						rData[:errorMessage] = "Paiement échoué"
						#rData[:debug] = payment.inspect
					end
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_feedback');
					rData = {
						:status => false,
						:errorMessage => "Le feedback du chauffeur concernant le client n'a pas été enregistré."
					}
				end
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

	####### Functions ###########

	def rendering(rData, including = nil, only = nil, methods = nil)
		respond_to do |format|
			format.json { render :json => rData.to_json(:only => only, :methods => methods, :include => including) }
		end
	end

	def check_code
		# Will stop any processing if the 'cheatcode' parameter is absent
		# This is to prevent request spamming
		if params['cheatcode'].nil? || params['cheatcode'] == ""
			rendering('') # Not giving any information about error
		end
	end

	def validate_token
		# Will stop any processing if the 'token' parameter is absent or invalid
		if params['token'].nil? || params['token'] == ""
			rendering('') # Not giving any information about error
		else
			@token = JSON.parse(decrypt_token(params['token']))
			if @token['user_id'].nil? || @token['account_type'].nil?
				rendering('')
			end

			@user = User.find_by(id: @token['user_id'])
			@account_type = @token['account_type']

			# If the token is expired (recieved token does not match user token)
			if params['token'] != @user.login_token
				rendering('')
			end
		end

		# Okay, you can go on with the call...
	end

	def validate_account_type
		# Will stop any processing if the 'account_type' parameter doesn't match the token's
		if @token['account_type'] == @user.account_type
			@account_type = @user.account_type
		elsif @token['account_type'] == 'client' && ['driver', 'partneradmin', 'admin', 'superadmin'].include?(@user.account_type)  # If a driver is using the client app
			@account_type = 'client'
		end

		# Okay, you can go on with the call...
	end

	def user_params
    	params.require(:user).permit(:name, :last_name, :email, :cellphone, :password, :password_confirmation, :facebookID)
    end

    def course_params
    	vars = {}
    	if params['course_data']['computed_price'] == '(prix après validation)'
			vars["computed_price"] = 0
			vars["need_review"] = true
    	else
			vars["computed_price"] = params['course_data']['computed_price']
			vars["need_review"] = false
    	end

		vars["from"] = params['course_data']['from_address']
		vars["to"] = params['course_data']['to_address']
		vars["date_when"] = params['course_data']['date']
		vars["time_when"] = params['course_data']['time']
		vars["car_type"] = params['course_data']['car_type']
		vars["course_type"] = params['course_data']['course_type']
		vars["stops"] = params['course_data']['stops']
		vars["computed_distance"] = params['course_data']['computed_distance']
		vars["computed_duration"] = params['course_data']['computed_duration']

		return vars
    end

   	def send_sms(to, contents)
   		if to[0] == '0'
   			to.sub! '0', '+33'
   		end

  		@twilio_client = Twilio::REST::Client.new Rails.application.secrets.twilio_sid, Rails.application.secrets.twilio_token
		@twilio_client.account.sms.messages.create(
			:from => "+13852157506",
			:to => to,
			:body => contents
		)
		rData = {:status => true}

        #twilio_client = Twilio::REST::Client.new Rails.application.secrets.twilio_sid_dev, Rails.application.secrets.twilio_token_dev
		#@twilio_client.account.sms.messages.create(
		#  :from => "+15005550006",
		#  :to => to,
		#  :body => contents
		#)
		#rData = {:status => true}
	end

	def distance_between(p1_lat, p1_lng, p2_lat, p2_lng)
		if p1_lat.nil? || p1_lng.nil? || p2_lat.nil? || p2_lng.nil? then return 0 end
		e = Math::PI*(p2_lat)/180
		f = Math::PI*(p2_lng)/180
		g = Math::PI*p1_lat/180
		h = Math::PI*p1_lng/180

		i = (Math.cos(e)*Math.cos(g)*Math.cos(f)*Math.cos(h)+Math.cos(e)*Math.sin(f)*Math.cos(g)*Math.sin(h)+Math.sin(e)*Math.sin(g));
		j = (Math.acos(i))

		return (6371*j).round(3)
	end

	def convert_distance_to_time(distance)
		time = (distance*60/50).round
		if time == 0 then time = 1 end # Can't wait for 0 minutes yo
		return time
	end

    def crypt_token(token)
    	public_key_file = 'naveco-async-calls-public';
    	public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
    	return Base64.strict_encode64(public_key.public_encrypt(token))
    end

    def decrypt_token(token)
    	private_key_file = 'naveco-async-calls';
    	private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), Rails.application.secrets.private_key_password)
    	return private_key.private_decrypt(Base64.decode64(token))
    end
end