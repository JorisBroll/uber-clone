class AjaxFunctionsController < ApplicationController
	before_action :partneradmins_only

	layout 'ajax'
	def get_pos
		@users = [User.find(34), User.find(36)]
		@users.each_with_index do |u, i|
			@users[i] = [u.pos_lat.to_f, u.pos_lon.to_f]
		end
		
		respond_to do |format|
			format.json { render :json => @users }
		end
	end
	def get_courses
		if (currently_admining_partner? || current_partner) && params['partner_id'] == 'current'
			@coursesdd = current_partner.courses.where("status = ?", params['status'].to_i)
		elsif !params['partner_id'].nil? && params['partner_id'] != 'current'
			@courses = Partner.find_by(id: params['partner_id']).courses.where("status = ?", params['status'].to_i)
		else
			@courses = Course.where("status = ?", 2)
		end
		respond_to do |format|
			format.json { render :json => @courses }
		end
	end

	def get_course_price
		respond_to do |format|
			format.json { render :json => 'hello' }
		end
		
	end
end
