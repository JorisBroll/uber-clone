class Admin::StaticPagesController < ApplicationController
	before_action :admins_only

	include ApplicationHelper
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
		if !params['recap'].nil?
			@date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
		else
			@date = Time.zone.now
		end
		@courses = Course.where("date_when >= ? AND date_when <= ?", @date.beginning_of_month, @date.end_of_month)
		@totalPrice = 0
		@totalPriceAfterCodes = 0
		@totalNavecoMargin = @courses.where("status = ? AND payment_status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_statuses[:not_paid], Course.payment_bies[:partner]).map {|s| price_afterPromo(s, 'naveco')}.reduce(0, :+)
		@totalPartnersShare = @courses.where("status = ? AND payment_status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_statuses[:not_paid], Course.payment_bies[:partner]).map {|s| price_afterPromo(s, 'partner')}.reduce(0, :+)
		@courses.where("status = ?", Course.statuses[:done]).each do |course|
			@totalPrice += course.computed_price
			afterCodePrice = price_afterPromo(course)
			@totalPriceAfterCodes += afterCodePrice
		end
		@unpaidCourses = @courses.where("status = ? AND payment_status = ?", Course.statuses[:done], Course.payment_statuses[:not_paid]).order('payment_status ASC')
	
		@partners = Partner.all
		@companies = Company.all
	end

	def monthly_pdf
		if !params['p'].nil?
			@partner = Partner.find_by(id: params['p'])
			if !params['recap'].nil?
				@date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
			else
				@date = Time.zone.now
			end
			@courses = @partner.courses.where("date_when >= ? AND date_when <= ? AND status = ?", @date.beginning_of_month, @date.end_of_month, Course.statuses[:done]).order(date_when: :asc)
			@courses_to_naveco = @courses.where("payment_by = ?", Course.payment_bies[:partner])
			
			@totals = {
				:ttc => (@courses.map {|s| price_afterPromo(s, 'partner')}.reduce(0, :+)).round(2),
				:ht => ((@courses.map {|s| price_afterPromo(s, 'partner')}.reduce(0, :+))*0.9).round(2),
				:tva => ((@courses.map {|s| price_afterPromo(s, 'partner')}.reduce(0, :+))*0.1).round(2),
				:naveco_collected => (@courses_to_naveco.map {|s| price_afterPromo(s)}.reduce(0, :+)).round(2),
				:naveco_collected_lifetime => @partner.courses.where("status = ? AND payment_by = ?", Course.statuses[:done], Course.payment_bies[:partner])
			}

			(@courses_to_naveco.map {|s| price_afterPromo(s, 'naveco')}.reduce(0, :+)).round(2)

			@naveco = Partner.find(1)

			render :pdf => "file_name", :template => 'application/invoice.pdf.erb'
		else

		end
	end
end