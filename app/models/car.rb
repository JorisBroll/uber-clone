class Car < ActiveRecord::Base
	belongs_to :partner, inverse_of: :cars
	belongs_to :user, inverse_of: :cars
	belongs_to :driver, class_name: 'User', foreign_key: "driven_by", inverse_of: :car
	has_many :courses, inverse_of: :cars

	Car_types = {
		:berline => {
			name: "Berline"
		},
		:van => {
			name: "Van"
		},
		:eco => {
			name: "Eco"
		}
	}
	enum car_type: Car_types.collect { |key, o| key }
	Car_types_select = Car_types.collect { |key, o| [o[:name], key] }
	
	validates :partner_id, presence: true
	validates :name, presence: true, length: { maximum: 50 }

	def name
		return "#{self.brand} #{self.model}"
	end
end
