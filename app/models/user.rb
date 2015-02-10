class User < ActiveRecord::Base
	belongs_to :partner, inverse_of: :users
  	belongs_to :created_by_user, class_name: 'User', foreign_key: "created_by"
  	belongs_to :sponsored_by, class_name: 'User', foreign_key: "sponsored_by"
	has_many :courses, inverse_of: :user
	has_many :person, :foreign_key => "created_by"
	has_many :sponsors, class_name: 'User', :foreign_key => "sponsored_by", inverse_of: :sponsored_by
	has_many :drives_courses, class_name: 'Course', foreign_key: "driver_id", inverse_of: :driver
	has_many :notifications, inverse_of: :user
	has_many :payment_infos, inverse_of: :user
	has_one :car, class_name: 'Car', :foreign_key => "driven_by", inverse_of: :driver
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
		:break => {
			:name => "En pause"
		},
		:busy => {
			:name => "Occupé"
		}
	}

	has_attached_file :photo
	validates_attachment_content_type :photo, :content_type => /\Aimage\/.*\Z/
	def photo_url
        photo.url
    end
	
	enum account_type: Account_types.collect { |key, o| key }
	enum status: Status.collect { |key, o| key }
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

	attr_accessor :mpos_latLng
	attr_accessor :mpos_deg

	def pos_latLng
		return {
			:lat => self.pos_lat,
			:lng => self.pos_lon
		}
	end

	def minimal_valid?
		if !self.name.blank? && !self.cellphone.blank?
			return true
		else
			return false
		end
	end
end