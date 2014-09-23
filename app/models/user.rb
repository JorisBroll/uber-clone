class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	enum account_type: [ :admin, :driver, :client ]
	Account_type_alias = [ ['Administrateur', :admin], ['Conducteur', :driver], ['Client', :client] ]
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
	                format:     { with: VALID_EMAIL_REGEX },
	                uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
end