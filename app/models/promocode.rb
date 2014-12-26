class Promocode < ActiveRecord::Base
	has_and_belongs_to_many :users
	has_many :courses, inverse_of: :promocode

	Effect_types = {
		:percent => {
			:name => "Pourcentage du total d'une course (%)"
		},
		:fixed => {
			:name => "Réduction fixe (€)"
		}
	}
	enum effect_type: Effect_types.collect { |key, o| key }
	Effect_type_select = Effect_types.collect { |key, o| [o[:name], key] }


	Effect_lengths = {
		:days => {
			:name => "Nombre de jours"
		},
		:uses => {
			:name => "Nombre d'utilisations"
		},
		:once_every_x => {
			:name => "Une fois toutes les n courses"
		}
	}
	enum effect_length: Effect_lengths.collect { |key, o| key }
	Effect_length_select = Effect_lengths.collect { |key, o| [o[:name], key] }
end
