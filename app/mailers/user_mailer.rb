class UserMailer < ActionMailer::Base
	default from: "mailer@nav-eco.fr"

	def custom_email(to, subject, contents)
		@contents = contents

		mail(to: to, subject: subject)
	end
end
