class Course < ActiveRecord::Base
	belongs_to :user, inverse_of: :courses
	belongs_to :car, inverse_of: :courses
	belongs_to :partner, inverse_of: :courses
	belongs_to :company, inverse_of: :courses
	belongs_to :created_by_user, class_name: 'User', foreign_key: "created_by"
	belongs_to :driver, class_name: 'User', foreign_key: "driver_id", inverse_of: :drives_courses
	belongs_to :promocode, inverse_of: :courses

	enum status: [ :inactive, :canceled, :in_progress, :done ]
	Status_alias = {'inactive' => "Inactive", 'canceled' => "Annulée", 'in_progress' => "En cours", 'done' => "Terminée"}
	Status_alias_css = {'inactive' => "", 'canceled' => "danger", 'in_progress' => "info", 'done' => "success"}
	Status_select = [ [Status_alias['inactive'], :inactive], [Status_alias['canceled'], :canceled], [Status_alias['in_progress'], :in_progress], [Status_alias['done'], :done] ]

	Payment_whens = {
		:direct_debit => {
			:name => "Débit immédiat"
		},
		:defer => {
			:name => "Différé en fin de mois"
		}
	}
	enum payment_when: Payment_whens.collect { |key, o| key }

	Payment_status = {
		:not_paid => {
			:name => "À faire payer"
		},
		:paid => {
			:name => "Déjà payé"
		}
	}
	enum payment_status: Payment_status.collect { |key, o| key }

	Payment_by = {
		:client => {
			:name_admin => "Paiement direct par client",
			:name_partneradmin => "Payé à Naveco"
		},
		:company => {
			:name_admin => "Paiement par l'entreprise du client",
			:name_partneradmin => "Payé à Naveco"
		},
		:partner => {
			:name_admin => "Paiement au chauffeur",
			:name_partneradmin => "À encaisser par le chauffeur"
		}
	}
	enum payment_by: Payment_by.collect { |key, o| key }

	Course_type = {
		:now => {
			:name => "Immédiate"
		},
		:later => {
			:name => "Différée"
		}
	}
	enum course_type: Course_type.collect { |key, o| key }

	enum car_type: Car::Car_types.collect { |key, o| key }

	def date_when_s
		unless self.date_when.nil? then self.date_when.strftime('%d/%m/%Y') else "PAS DE DATE" end
	end
	def time_when_s
		unless self.time_when.nil? then self.time_when.strftime('%Hh%M') else "PAS D'HEURE" end
	end

	def trip_wait_start_sec
		self.trip_wait_start.to_f * 1000
	end
	def trip_started_sec
		self.trip_started.to_f * 1000
	end
	def trip_finished_sec
		self.trip_finished.to_f * 1000
	end

end