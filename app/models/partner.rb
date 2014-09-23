class Partner < ActiveRecord::Base
	has_many :cars, dependent: :destroy, inverse_of: :partner
end
