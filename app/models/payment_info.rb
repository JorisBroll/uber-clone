class PaymentInfo < ActiveRecord::Base
	belongs_to :user, inverse_of: :payment_infos
  	
	Infos_types = {
		:paypal => {
			:name => "Paypal"
		},
		:card => {
			:name => "Carte banquaire"
		}
	}
	
	enum infos_type: Infos_types.collect { |key, o| key }
	Infos_types_select = Infos_types.collect { |key, o| [o[:name], key] }
	def infos_type_s
		return PaymentInfo::Infos_types[self.infos_type.to_sym][:name]
	end
end