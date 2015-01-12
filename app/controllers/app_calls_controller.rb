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
			
			user.update(login_token: token)
			rData = {:status => true, :loginData => {:token => token} }
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

	####### CLIENT APP ###########

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

		####### Cars REST ###########
		def cars_index
			rData = {}

			rData[:cars] = @user.partner.cars

			rendering(rData)
		end

		####### Courses REST ###########
		def courses_index
			rData = {}

			rData[:courses] = @user.drives_courses.order(date_when: :desc, time_when: :desc)

			rendering(rData)
		end

	####### Functions ###########

	def rendering(rData)
		respond_to do |format|
			format.json { render :json => rData }
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