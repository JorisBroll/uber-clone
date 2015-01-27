class AppTools

	def self.buildList(type, ofWhat)
		return self.objects.slice(:user, :partner, :company).collect {|key, o| [o[:name], key]}
	end

		private

		def self.objects
			return {
				:user => {
					:name => 'Utilisateur',
					:with_article => "l'utilisateur"
				},
				:course => {
					:name => 'Course',
					:with_article => "la course"
				},
				:partner => {
					:name => 'Entreprise partenaire',
					:with_article => "l'entreprise partenaire"
				},
				:company => {
					:name => 'Entreprise cliente',
					:with_article => "l'entreprise cliente"
				},
				:promocode => {
					:name => 'Code promotion',
					:with_article => "le code promotion"
				},
				:payment => {
					:name => 'Paiement',
					:with_article => "le paiement"
				},
				:event => {
					:name => 'Événement',
					:with_article => "l'évènement"
				},
				:log => {
					:name => 'Entrée de journal',
					:with_article => "l'entrée de journal"
				},
				:car => {
					:name => 'Voiture',
					:with_article => "la voiture"
				}
			}
		end
end