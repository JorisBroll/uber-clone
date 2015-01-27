class AppCallsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :check_code
	before_action :validate_token, :except => [:signup, :login, :fb_signup_login, :activate_code]
	before_action :validate_account_type, :except => [:signup, :login, :fb_signup_login, :activate_code]

	require 'openssl'

	####### Login/Signup ###########

	def signup # Call to make new users
		rData = {}

		user = User.new(user_params)
		user.enabled = false
		user.account_type = 'client'
		user.activation_code = (0...5).map { ('A'..'Z').to_a[rand(26)] }.join
		if user.valid?
			user.save
			rData['user_created'] = {:status => true, :activation_code => user.activation_code, :id => user.id}
		else
			rData['user_created'] = {:status => false, :errors => user.errors.full_messages}
			rData['status'] = false
		end


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
		user = User.find_by(email: params['credentials']['email']).try(:authenticate, Base64.decode64(params['credentials']['password']))

		if user && !user.enabled
			rData = {:status => false, :errorMessage => 'Utilisateur non activé. Veuillez contacter Naveco pour résoudre le problème.' }
		elsif user
			uncrypted_token = {:user_id => user.id.to_s, :deliver_date => Time.zone.now}
			if params['credentials']['account_type'] == 'driver' && user.account_type == 'driver'
				uncrypted_token[:account_type] = 'driver'
			else
				uncrypted_token[:account_type] = 'client'
			end

			token = crypt_token(uncrypted_token.to_json)
			#token = uncrypted_token.to_json
			
			user.login_token = token
			if user.save
				rData = {:status => true, :loginData => {:token => token} }
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

		if user
			#user.name = params['user']['first_name']
			#user.last_name = params['user']['last_name']
			uncrypted_token = {:user_id => user.id.to_s, :deliver_date => Time.zone.now, :account_type => 'client'}.to_json
			token = crypt_token(uncrypted_token)
			
			user.update(login_token: token)
			rData = {:status => true, :loginData => {:token => token} }
		else
			params['user']['password'] = 'NobodyGivesAShit'+(0...50).map { ('0'..'Z').to_a[rand(26)] }.join
			params['user']['password_confirmation'] = params['user']['password']

			user = User.new(user_params)
			user.enabled = false
			user.account_type = 'client'
			user.activation_code = (0...5).map { ('A'..'Z').to_a[rand(26)] }.join

			if user.valid?
				user.save
				rData[:user_created] = {:status => true, :activation_code => user.activation_code, :id => user.id}
			else
				rData[:user_created] = {:status => false, :errors => user.errors.full_messages}
				rData[:status] = false
			end
		end
		

		rendering(rData)
	end

	def logout
		@user.login_token = nil
		@user.save
		rendering({})
	end

	####### CLIENT APP ###########

		####### Courses REST ###########
		def course_create
			rData = {}

			course = @user.courses.build(course_params)

			if course.valid?
				course.save
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
			end

			rendering(rData)
		end

		def course_check_driver
			rData = {}

			course = @user.courses.find_by(id: params['course_id'])

			if !course.nil?
				rData = { :status => true }
				if !course.driver_id.nil?
					driver = User.select(:id, :name, :last_name, :cellphone, :photo).find_by(id: course.driver_id)
					rData[:driver] = driver
					rData['driver_status'] = true
				else
					rData['driver_status'] = false
				end
			else
				rData = {
					:status => false
				}
			end

			rendering(rData)
		end

		####### Payment Infos REST ###########
		def payment_infos_index
			rData = {}

			rData[:payment_infos] = @user.payment_infos

			rendering(rData)
		end

		def payment_infos_create

			if !params['payment_info_card'].nil?
				payment_infos = PaymentInfo.new(params.require(:payment_info_card).permit(:card_number, :card_expiration_month, :card_expiration_year, :card_verification))
			elsif !params['payment_info_paypal'].nil?
				payment_infos = PaymentInfo.new(params.require(:payment_info_paypal).permit(:paypal_email, :paypal_password))
			end

			if payment_infos.valid?
				payment_infos.user_id = @user.id
				payment_infos.save
				rData = {
					:status => true
				}
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			#rData[:payment_infos] = payment_infos.inspect

			rendering(rData)
		end

		def payment_infos_destroy
			payment_infos = @user.payment_infos.find_by(id: params['payment_info_id'])
			if payment_infos.destroy
				rData = {
					:status => true
				}
			else
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end


	####### DRIVER APP ###########

		####### User REST ###########
		def profile_index
			rData = @user
			rendering(rData)
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

		def update_photo
			rData = {}

			#@user.cellphone = params['number']

			#if @user.save
			#	Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'update_cellphone');
			#	rData = {
			#		:status => true
			#	}
			#else
			#	Log.create(user_id: @user.id, target_type: 0, target_id: @user.id, action: 'fail_update_cellphone');
			#	rData = {
			#		:status => false,
			#		:errorMessage => ''
			#	}
			#end
			
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

			cars = @user.partner.cars

			thisMorning = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 8, 0, 0)

			cars.each do |car|
				if !car.last_selected.nil? && car.last_selected < thisMorning
					car.update(driven_by: nil)
				end
			end

			rData[:cars] = @user.partner.cars

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
		def courses_index
			rData = {}

			rData[:courses] = @user.drives_courses.where('status = ?', Course.statuses[:inactive]).order(date_when: :desc, time_when: :desc).select(:id, :from, :to, :date_when, :time_when, :user_id, :created_at)

			rendering(rData, [ :user => {:only => [:id, :name, :last_name, :cellphone, :email, :photo]} ])
		end

		def course_cancel
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course
				course.status = Course.statuses[:canceled]
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
				rData = {
					:status => false,
					:errorMessage => 'Paramètres incorrects'
				}
			end

			rendering(rData)
		end

		def courses_query_new
			rData = {}

			#course = Course.find(1)
			courses_noDriver = Course.where('driver_id IS NULL AND status = ?', Course::statuses[:inactive]).order(id: :asc)
			r = nil
			found = false

			courses_noDriver.each do |course|
				r = course
				if course.rejected_by.nil? || !course.rejected_by.include?(@user.id)
					found = true
					break
				end
			end

			if !found then r = nil end

			rData = {
				:status => true,
				:course => r
			}

			rendering(rData)
		end

		def course_accept
			rData = {}

			course = Course.find_by(id: params['course_id'])

			if course
				course.driver_id = @user.id
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



		def incoming_sms
			course = Course.find_by(id: params['course_id'])

			if course
				#@twilio_client = Twilio::REST::Client.new Rails.application.secrets.twilio_sid, Rails.application.secrets.twilio_token

				#@twilio_client.account.sms.messages.create(
				#  :from => "+13852157506",
				#  :to => "+33676665045",
				#  :body => "Course [##{course.id}] : Votre chauffeur est en route !"
				#)
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
				@twilio_client = Twilio::REST::Client.new Rails.application.secrets.twilio_sid, Rails.application.secrets.twilio_token

				#@twilio_client.account.sms.messages.create(
				#  :from => "+13852157506",
				#  :to => @user.cellphone,
				#  :body => "Course [##{course.id}] : Votre chauffeur est en arrivé !"
				#)
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
			course = Course.find_by(id: params['course_id'])

			if course
				course.trip_finished = Time.now
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'end');
					rData = {
						:status => true
					}
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_end');
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

		def send_feedback
			course = Course.find_by(id: params['course_id'])

			if course
				course.trip_feedback = params['feedback_value']
				if course.save
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'feedback');
					rData = {
						:status => true
					}
					course.update(status: Course::statuses[:done])
				else
					Log.create(user_id: @user.id, target_type: 1, target_id: course.id, action: 'fail_feedback');
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

	####### Functions ###########

	def rendering(rData, including = nil)
		respond_to do |format|
			format.json { render :json => rData, :include => including }
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
		end

		# Okay, you can go on with the call...
	end

	def validate_account_type
		# Will stop any processing if the 'account_type' parameter doesn't match the token's
		if @token['account_type'] == @user.account_type
			@account_type = @user.account_type
		elsif @token['account_type'] == 'client' && @user.account_type == 'driver' # If a driver is using the client app
			@account_type = 'client'
		end

		# Okay, you can go on with the call...
	end

	def user_params
    	params.require(:user).permit(:name, :last_name, :email, :cellphone, :password, :password_confirmation, :facebookID)
    end

    def course_params
    	vars = {
			"from" => params['course_data']['from_address'],
			"to" => params['course_data']['to_address'],
			"date_when" => params['course_data']['date'],
			"time_when" => params['course_data']['time'],
			"car_type" => params['course_data']['car_type']
		}
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