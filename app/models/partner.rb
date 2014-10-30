class Partner < ActiveRecord::Base
	has_many :cars, dependent: :destroy, inverse_of: :partner
	has_many :users, inverse_of: :partner
	has_many :courses, inverse_of: :partner
	has_many :companies, inverse_of: :partner

	Statuses = {
		:company => {
			:name => "Entreprise"
		},
		:taxi => {
			:name => "taxi"
		},
		:self_employed => {
			:name => "Auto entrepreneur"
		}
	}

	enum status: Statuses.collect { |key, o| key }
	Statuses_select = Statuses.collect { |key, o| [o[:name], key] }


	validates :name, presence: true, length: { maximum: 50 }
end
