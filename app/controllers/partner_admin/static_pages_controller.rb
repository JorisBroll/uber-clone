class PartnerAdmin::StaticPagesController < ApplicationController
	before_action :partneradmins_only

	include CoursesHelper
	
	
	def map
		@partner = current_partner.users.find_by(account_type: 'driver')
	end
	def monthly
		@partner = current_partner
		@courses = @partner.courses.where("date_when >= ? AND date_when <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
		@totalPrice = 0
		@totalPriceAfterCodes = 0
		@totalNavecoMargin = 0
		@courses.where("status = ?", Course.statuses[:done]).each do |course|
			@totalPrice += course.computed_price
			afterCodePrice = price_afterPromo(course)
			@totalPriceAfterCodes += afterCodePrice
			@totalNavecoMargin += (course.computed_price - afterCodePrice)
		end
		@unpaidCourses = @courses.where("status = ? AND payment_status = ?", Course.statuses[:done], Course.payment_statuses[:not_paid]).order('payment_status ASC')
		@toNaveco = @courses.where("status = ? AND payment_status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_statuses[:not_paid], Course.payment_bies[:partner]).order('payment_status ASC')
	end
end
