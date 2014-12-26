class Admin::CoursesController < ApplicationController
	before_action :admins_only

	include CoursesHelper

	def index
		@courses = Course.all
	end
	def show
		@course = Course.find(params[:id])
		@partner = @course.partner
		@client = @course.user
		@driver = @course.driver
		@company = @course.company
		@car = @course.car
		@promocode = @course.promocode

		# Check if promo is taken into account
		#@promo_amount = checkPromo(@course) 
	end
	def new
		@course = Course.new
	end
	def create
		@course = Course.new(course_params)

		@course.promocode_amount = checkPromo(@course)

		if @course.save
			flash[:success] = "La course n°"+@course.id.to_s+" a été créée."
			Log.create(user_id: current_user.id, target_type: 1, target_id: @course.id, action: 'create')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			redirect_to admin_course_path(@course)
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

		@course.promocode_amount = checkPromo(@course)

		if @course.update_attributes(course_params)
			flash[:success] = "La course n°"+@course.id.to_s+" a été modifiée avec succès."
			Log.create(user_id: current_user.id, target_type: 1, target_id: @course.id, action: 'update')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			Notification::make('warning', 'Course modifiée', "La course n°"+ @course.id.to_s+" du "+@course.date_when.to_s+" a été modifiée.", ['admins', 'partneradmins'], admin_course_path(@course))
			redirect_to admin_course_path(@course)
		else
			flash[:error] = "La course n'a pas pu être modifiée, veuillez réessayer :"
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_updated', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			render 'edit'
		end
	end
	def destroy
		@course = Course.find(params[:id]).destroy
	    flash[:success] = "Course supprimée."
	    Log.create(user_id: current_user.id, target_type: 1, target_id: @course.id, action: 'destroy')
	    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'course', 'id' => params[:id].to_s} })
	    redirect_to admin_courses_path
	end

		private

		    def course_params
		    	params['course']['stops'] = params['course']['stops'].to_json
		    	params.require(:course).permit(:from, :to, :date_when, :time_when, :computed_distance, :computed_duration, :computed_price, :stops_price, :promocode_amount, :commission, :stops, :nb_people, :nb_luggage, :user_id, :partner_id, :car_id, :company_id, :status, :notes, :created_by, :company_id, :promocode_id, :driver_id, :payment_when, :payment_by, :payment_status, :payment_type, :flight_number, :need_review)
		    end

end
