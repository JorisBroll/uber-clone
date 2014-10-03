class Car < ActiveRecord::Base
	belongs_to :partner, inverse_of: :cars
	belongs_to :user, inverse_of: :cars
	has_many :courses, inverse_of: :cars

	enum car_type: [ :berline, :van, :eco ]
	Car_type_alias = [ ['Berline', :berline], ['Van', :van], ['Eco', :eco] ]
	
	validates :partner_id, presence: true
	validates :name, presence: true, length: { maximum: 50 }
end
