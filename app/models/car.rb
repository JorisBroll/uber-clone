class Car < ActiveRecord::Base
	belongs_to :partner, inverse_of: :cars
end
