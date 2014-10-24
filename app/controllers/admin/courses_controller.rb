class Admin::CoursesController < ApplicationController
	before_action :admins_only

	def index
		@courses = Course.all
	end
	def show
		@course = Course.find(params[:id])
	end
	def new
		@course = Course.new
	end
	def create
		@course = Course.new(course_params)
		if @course.save
			flash[:success] = "La course n°"+@course.id.to_s+" a été créée."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			redirect_to admin_courses_path
	    else
	    	flash[:error] = "La course n'a pas pu être créée, veuillez réessayer :"
	    	AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'course'} })
	    	render 'new'
	    end

	end
	def edit
		@course = Course.find(params[:id])
		@users = User.all
	end
	def update
		@course = Course.find(params[:id])

		if @course.update_attributes(course_params)
			flash[:success] = "La course n°"+@course.id.to_s+" a été modifiée avec succès."
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			redirect_to admin_courses_path
			make_notif('warning', 'Course modifiée', "La course n°"+ @course.id.to_s+" du "+@course.date_when.to_s+" a été modifiée.")
		else
			flash[:error] = "La course n'a pas pu être modifiée, veuillez réessayer :"
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_updated', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			render 'edit'
		end

	end

		private

		    def course_params
		    	params['course']['stops'] = params['course']['stops'].to_json
		    	params.require(:course).permit(:from, :to, :date_when, :time_when, :computed_distance, :computed_duration, :computed_price, :stops, :nb_people, :user_id, :partner_id, :status, :notes, :payment_when)
		    end

		    def make_notif(type, title, content)
		    	if !@current_partner.nil?
		    		@colleagues = @current_partner.users
		    		@colleagues.each do |u|
				    	@notification = u.notifications.build(notif_type: 1, title: title, content: content)
						if @notification.save
							AppLogger.log ({'user_id' => current_user, 'action' => 'created', 'target_object' => {'type' => 'notification', 'id' => @course.id.to_s} })
						else
							AppLogger.log ({'user_id' => current_user, 'action' => 'fails_create', 'target_object' => {'type' => 'notification'} })
						end
					end
				end
		    end

end