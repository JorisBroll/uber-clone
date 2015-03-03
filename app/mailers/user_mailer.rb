class UserMailer < ActionMailer::Base
	default from: "mailer@nav-eco.fr"

	def custom_email(to, subject, contents)
		@contents = contents

		mail(to: to, subject: subject)
	end
	def custom_backoffice_email(to, subject, contents)
		@contents = contents

		mail(to: to, subject: subject)
	end
	def invoice_email(to, subject, contents, course_object, client_object, course_prix, course_duration, partner_object)
		@contents = contents
		@course = course_object
		@user = client_object
		@prix = course_prix
		@duree = course_duration
		@partner = partner_object

		mail(to: to, subject: subject)
	end
end
