class Cars < ActiveRecord::Base
	enum car_type: [ :berline, :van ]
end
