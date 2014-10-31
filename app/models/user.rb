class User < ActiveRecord::Base
	belongs_to :partner, inverse_of: :users                          
  	belongs_to :created_by_user, class_name: 'User', foreign_key: "created_by"
	has_many :courses, inverse_of: :user
	has_many :person, :foreign_key => "created_by"
	has_many :cars, inverse_of: :user
	has_many :notifications, inverse_of: :user
	has_one :promocode, inverse_of: :users
	has_and_belongs_to_many :companies

	before_save { self.email = email.downcase }

	Account_types = {
		:superadmin => {
			:name => "Gérant",
			:privileges => true
		},
		:admin => {
			:name => "Administrateur",
			:privileges => {
				:users => ['show', 'edit', 'delete'],
				:courses => ['show', 'edit', 'delete']
			}
		},
		:partneradmin => {
			:name => "Administrateur d'entreprise"
		},
		:driver => {
			:name => "Conducteur"
		},
		:client => {
			:name => "Client"
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