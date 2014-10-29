class Partner < ActiveRecord::Base
	has_many :cars, dependent: :destroy, inverse_of: :partner
	has_many :users, inverse_of: :partner
	has_many :courses, inverse_of: :partner
	has_many :companies, inverse_of: :partner

	validates :name, presence: true, length: { maximum: 50 }
end
