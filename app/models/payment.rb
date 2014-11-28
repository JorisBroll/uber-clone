class Payment < ActiveRecord::Base
	Methods = {
		:paypal => {
			:name => "Paypal"
		},
		:card => {
			:name => "Carte banquaire"
		},
		:cash => {
			:name => "En liquide"
		}
	}
	
	enum method: Methods.collect { |key, o| key }
end