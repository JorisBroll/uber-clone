class AppTools

	def self.buildList(type, ofWhat)
		return self.objects.slice(:user, :partner, :company).collect {|key, o| [o[:name], key]}
	end

		private

		def self.objects
			return {
				:user => {
					:name => 'Utilisateur'
				},
				:course => {
					:name => 'Course'
				},
				:partner => {
					:name => 'Entreprise partenaire'
				},
				:company => {
					:name => 'Entreprise cliente'
				},
				:promocode => {
					:name => 'Code promotion'
				},
				:payment => {
					:name => 'Paiement'
				},
				:event => {
					:name => 'Événement'
				},
			}
		end
end