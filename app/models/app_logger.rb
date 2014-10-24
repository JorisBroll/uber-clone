class AppLogger

	def self.log(hash=nil)
		@my_log ||= Logger.new("#{Rails.root}/log/app_events.log")
		@my_log.info(
			"L'utilisateur "+getUserString(hash['user_id'])+getActionString(hash['action'])+getTargetString(hash['target_object'])
		) unless hash.nil?
	end

		private

			def self.getUserString(user_id)
				@user = User.find(user_id)
				return @user.id.to_s+'/'+@user.name
			end
			def self.getActionString(action)
				case action
				when 'created'
					return " a crée "
				when 'fail_created'
					return " n'a pas pu créer "
				when 'updated'
					return " a modifié "
				when 'fail_updated'
					return " n'a pas pu modifier "
				when 'deleted'
					return " a supprimé "
				when 'fail_deleted'
					return " n'a pas pu supprimer "
				else
					return " a effectué une action inconnue "
				end
			end
			def self.getTargetString(target_object)
				string = ''
				case target_object['type']
				when 'notification'
					string += "la notification"
				when 'course'
					string += "la course"
				else
					string += "l'objet"
				end

				if !target_object['id'].nil?
					return string += " n°"+target_object['id']
				else
					return string += '.'
				end
			end
end