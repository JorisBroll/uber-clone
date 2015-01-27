class Log < ActiveRecord::Base
	enum target_type: AppTools.objects.collect { |key, o| key }

	def action_string
		case self.action
		when 'create'
			return " a crée "
		when 'fail_create'
			return " n'a pas pu créer "
		when 'update'
			return " a modifié "
		when 'fail_update'
			return " n'a pas pu modifier "
		when 'destroy'
			return " a supprimé "
		when 'fail_destroy'
			return " n'a pas pu supprimer "
		when 'select'
			return " a sélectionné "
		when 'fail_select'
			return " n'a pas pû sélectionner "
		when 'start'
			return " a commencé "
		when 'fail_start'
			return " n'a pas pû commencer "
		when 'end'
			return " a terminé "
		when 'fail_end'
			return " n'a pas pû terminer "
		else
			return self.action
		end
	end

	def target_string
		string = ''
		case self.target_type
		when 'notification'
			string += "la notification"
		when 'course'
			string += "la course"
		when 'user'
			string += "l'utilisateur"
		when 'promocode'
			string += "le code promotion"
		when 'company'
			string += "l'entreprise cliente"
		when 'partner'
			string += "l'entreprise partenaire"
		when 'car'
			string += "la voiture"	
		else
			string += "l'objet"
		end

		if !self.target_id.nil?
			return string += " n°"+target_id.to_s
		else
			return string += '.'
		end
	end
end
