class User < ActiveRecord::Base
	belongs_to :partner, inverse_of: :users                          
  	belongs_to :created_by_user, class_name: 'User', foreign_key: "created_by"
	has_many :courses, inverse_of: :users
	has_many :person, :foreign_key => "created_by"
	has_many :cars, inverse_of: :users
	#has_many :has_created, class_name: 'User', foreign_key: "created_by"   

	before_save { self.email = email.downcase }

	enum account_type: [ :admin, :partneradmin, :driver, :client ]
	Account_type_select = [ ['Administrateur', :admin], ["Administrateur d'entreprise", :partneradmin], ['Conducteur', :driver], ['Client', :client] ]
	Account_type_select_noadmin = [ ["Administrateur d'entreprise", :partneradmin], ['Conducteur', :driver], ['Client', :client] ]
	
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
	                format:     { with: VALID_EMAIL_REGEX },
	                uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
end