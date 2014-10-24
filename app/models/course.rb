class Course < ActiveRecord::Base
	belongs_to :user, inverse_of: :courses
	belongs_to :car, inverse_of: :courses
	belongs_to :partner, inverse_of: :courses
	belongs_to :company, inverse_of: :courses

	enum status: [ :inactive, :canceled, :in_progress, :done ]
	Status_alias = {'inactive' => "Inactive", 'canceled' => "Annulée", 'in_progress' => "En cours", 'done' => "Terminée"}
	Status_alias_css = {'inactive' => "", 'canceled' => "danger", 'in_progress' => "info", 'done' => "success"}
	Status_select = [ [Status_alias['inactive'], :inactive], [Status_alias['canceled'], :canceled], [Status_alias['in_progress'], :in_progress], [Status_alias['done'], :done] ]

	enum payment_when: [ :direct_debit, :defer ]
	Payment_whens = {
		'direct_debit' => {
			'name' => "Débit immédiat"
		},
		'defer' => {
			'name' => "Différé en fin de mois"
		}
	}
end
