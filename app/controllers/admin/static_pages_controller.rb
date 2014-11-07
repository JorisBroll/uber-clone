class Admin::StaticPagesController < ApplicationController
	before_action :admins_only

	include CoursesHelper
	
	def home
	    @users = User.all
	end

	def logout_partner
	    sign_out_partner
	    redirect_to admin_home_path
	end

	def map
		@partners = Partner.all
	end

	def monthly
		@courses = Course.where("date_when >= ? AND date_when <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month)
		@totalPrice = 0
		@totalPriceAfterCodes = 0
		@totalNavecoMargin = @courses.where("status = ? AND payment_status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_statuses[:not_paid], Course.payment_bies[:partner]).map {|s| price_afterPromo(s, true)}.reduce(0, :+)
		@totalPartnersShare = @courses.where("status = ? AND payment_status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_statuses[:not_paid], Course.payment_bies[:partner]).map {|s| price_afterPromo(s, false, true)}.reduce(0, :+)
		@courses.where("status = ?", Course.statuses[:done]).each do |course|
			@totalPrice += course.computed_price
			afterCodePrice = price_afterPromo(course)
			@totalPriceAfterCodes += afterCodePrice
			
		end
		@unpaidCourses = @courses.where("status = ? AND payment_status = ?", Course.statuses[:done], Course.payment_statuses[:not_paid]).order('payment_status ASC')
	
		@partners = Partner.all
		@companies = Company.all
	end

end