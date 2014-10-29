class User < ActiveRecord::Base
	belongs_to :partner, inverse_of: :users                          
  	belongs_to :created_by_user, class_name: 'User', foreign_key: "created_by"
	has_many :courses, inverse_of: :user
	has_many :person, :foreign_key => "created_by"
	has_many :cars, inverse_of: :user
	has_many :notifications, inverse_of: :user
	has_one :promocode, inverse_of: :user
	has_and_belongs_to_many :companies

	before_save { self.email = email.downcase }

	enum account_type: [:superadmin, :admin, :partneradmin, :driver, :client ]
	Account_type_select = [ ["Client", :client], ["Conducteur", :driver], ["Administrateur d'entreprise", :partneradmin], ["Administrateur", :admin], ["Gérant", :superadmin] ]
	Account_type_alias = {'superadmin' => "Gérant", 'admin' => "Administrateur", 'partneradmin' => "Administrateur d'entreprise", 'driver' => "Conducteur", 'client' => "Client"}
	Account_type_select_noadmin = [ ['Client', :client], ['Conducteur', :driver], ["Administrateur d'entreprise", :partneradmin] ]
	
	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
	                format:     { with: VALID_EMAIL_REGEX },
	                uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
end