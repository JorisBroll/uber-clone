class Payment < ActiveRecord::Base
	Methods = {
		:paypal => {
			:name => "Paypal"
		},
		:card => {
			:name => "Carte bancaire"
		},
		:transfer => {
			:name => "Virement"
		},
		:cash => {
			:name => "Espèce"
		}
	}
	
	enum method: Methods.collect { |key, o| key }
end