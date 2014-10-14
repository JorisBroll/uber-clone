class PartnerAdmin::StaticPagesController < ApplicationController
	before_action :partneradmins_only
	
	def home
		@partner = current_partner
		@partneradmins = @partner.users.where("account_type = ?", User.account_types[:admin])
		@drivers = @partner.users.where("account_type = ?", User.account_types[:driver])
		@cars = @partner.cars
		@courses = @partner.courses
	end
	def map
		@partner = current_partner.users.find_by(account_type: 'driver')
	end
end
