class AppCallsController < ApplicationController
	skip_before_action :verify_authenticity_token
	before_action :check_code

	require 'openssl'

	layout 'ajax'
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
		user = User.find_by(id: params['user_id'])
		
		if user.activation_code == params['activation_code'].upcase
			user.update(enabled: true)
			rData = {:status => true}
		else
			rData = {:status => false, :errors => ['Le code ne correspond pas.']}
		end

		rendering(rData)
	end

	def login # Call to log into the app popopo@test.fr
		user = User.find_by(email: params['credentials']['email']).try(:authenticate, Base64.decode64(params['credentials']['password']))

		if user
			uncrypted_token = {:user_id => user.id.to_s, :deliver_date => Time.zone.now}.to_json
			token = crypt_token(uncrypted_token)
			
			user.update(login_token: token)
			rData = {:status => true, :token => token }
		else
			rData = {:status => false, :message => 'Impossible de se connecter. Veuillez vérifier votre email/password' }
		end
		
		rendering(rData)
	end

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

		def user_params
	    	params.require(:user).permit(:name, :last_name, :email, :cellphone, :password)
	    end

	    def crypt_token(token)
	    	public_key_file = 'naveco-async-calls-public';
	    	public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
	    	return Base64.encode64(public_key.public_encrypt(token))
	    end

	    def decrypt_token(token)
	    	private_key_file = 'naveco-async-calls';
	    	private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), Rails.application.secrets.private_key_password)
	    	return private_key.private_decrypt(Base64.decode64(token))
	    end
end