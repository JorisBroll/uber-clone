class User < ActiveRecord::Base
	belongs_to :partner, inverse_of: :users                          
  	belongs_to :created_by_user, class_name: 'User', foreign_key: "created_by"
	has_many :courses, inverse_of: :user
	has_many :person, :foreign_key => "created_by"
	has_many :cars, inverse_of: :user
	has_many :notifications, inverse_of: :user
	has_and_belongs_to_many :promocodes
	has_and_belongs_to_many :companies

	before_save { self.email = email.downcase }

	Account_types = {
		:superadmin => {
			:name => "Gérant",
			:weight => 1
		},
		:admin => {
			:name => "Administrateur",
			:weight => 2
		},
		:partneradmin => {
			:name => "Administrateur d'entreprise",
			:weight => 3
		},
		:driver => {
			:name => "Conducteur",
			:weight => 4
		},
		:client => {
			:name => "Client",
			:weight => 5
		}
	}

	Status = {
		:ready => {
			:name => "En ligne et prêt"
		},
		:offline => {
			:name => "Hors-ligne"
		},
		:on_break => {
			:name => "En pause"
		}
	}
	
	enum account_type: Account_types.collect { |key, o| key }
	Account_types_select = Account_types.collect { |key, o| [o[:name], key] }
	Account_types_select_partneradmin = Account_types.collect { |key, o|
		if ![:superadmin, :admin].include? key
			[o[:name], key]
		end
	}

	validates :name, presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence:   true,
	                format:     { with: VALID_EMAIL_REGEX },
	                uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
end