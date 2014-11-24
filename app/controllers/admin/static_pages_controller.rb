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
			@select_date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
			@date = {
				:start => @select_date.beginning_of_month,
				:end => @select_date.end_of_month
			}
		elsif !params['date_start'].nil?
			@date = {
				:start => params['date_start'].to_date,
				:end => params['date_end'].to_date
			}
		else	
			@date = {
				:start => Time.zone.now.beginning_of_month,
				:end => Time.zone.now.end_of_month
			}
		end
		@courses = Course.where("date_when >= ? AND date_when <= ? AND status = ?", @date[:start], @date[:end], Course.statuses[:done])
		@totals = {
			:full_price => @courses.map {|s| s.computed_price}.reduce(0, :+),
			:promo_price => @courses.map {|s| price_afterPromo(s)}.reduce(0, :+),
			:naveco_share => @courses.map {|s| price_afterPromo(s, 'naveco')}.reduce(0, :+),
			:partner_share => @courses.map {|s| price_afterPromo(s, 'partner')}.reduce(0, :+)
		}

		@chartData = [
			{:period => Date.new(2014, 6, 30), :ca => 450, :course_count => 10},
			{:period => Date.new(2014, 7, 31), :ca => 1000, :course_count => 23},
			{:period => Date.new(2014, 8, 31), :ca => 800, :course_count => 16},
			{:period => Date.new(2014, 9, 30), :ca => 3500, :course_count => 50},
			{:period => Date.new(2014, 10, 31), :ca => 9000, :course_count => 120},
			{:period => @date[:end], :ca => 900, :course_count => 23}
		]
		
		@unpaidCourses = @courses.where("status = ? AND payment_status = ?", Course.statuses[:done], Course.payment_statuses[:not_paid]).order('payment_status ASC')
	
		@partners = Partner.all
		@companies = Company.all
	end

	def monthly_pdf
		if !params['p'].nil?
			@partner = Partner.find_by(id: params['p'])
			if !params['recap'].nil?
				@select_date = Date.new(params['recap']['date(1i)'].to_i, params['recap']['date(2i)'].to_i, 1)
				@date = {
					:start => @select_date.beginning_of_month,
					:end => @select_date.end_of_month
				}
			elsif !params['date_start'].nil?
				@date = {
					:start => params['date_start'].to_date,
					:end => params['date_end'].to_date
				}
			else	
				@date = {
					:start => Time.zone.now.beginning_of_month,
					:end => Time.zone.now.end_of_month
				}
			end
			@courses = @partner.courses.where("date_when >= ? AND date_when <= ? AND status = ?", @date[:start], @date[:end], Course.statuses[:done]).order(date_when: :asc)
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