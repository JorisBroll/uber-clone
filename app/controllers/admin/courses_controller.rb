class Admin::CoursesController < ApplicationController
	before_action -> { requiredWeight User::Account_types[:partneradmin][:weight] }
	before_action -> { check_privileges }, only: [:show, :edit, :update, :destroy]
	before_action -> { protect_destroy }, only: [:destroy]

	include CoursesHelper

	def index
		if userWeight <= User::Account_types[:admin][:weight]
			@courses = Course.all
		else
			@courses = current_partner.courses
		end
	end
	def show
		@partner = @course.partner
		@client = @course.user
		@driver = @course.driver
		@company = @course.company
		@car = @course.car
		@promocode = @course.promocode

		# (debug) Check if promo is taken into account
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
			
			if @course.need_review? then Notification::make('warning', 'Course à valider', "La course n°"+ @course.id.to_s+" du "+@course.date_when.to_s+" a besoin d'être validée.", ['admins'], admin_course_path(@course)) end

			redirect_to admin_course_path(@course)
	    else
	    	flash[:error] = "La course n'a pas pu être créée, veuillez réessayer :"
	    	AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'course'} })
	    	render 'new'
	    end

	end
	def edit

	end
	def update
		@course.promocode_amount = checkPromo(@course)

		if @course.update_attributes(course_params)
			flash[:success] = "La course n°"+@course.id.to_s+" a été modifiée avec succès."
			Log.create(user_id: current_user.id, target_type: 1, target_id: @course.id, action: 'update')
			AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			
			Notification::make('warning', 'Course modifiée', "La course n°"+ @course.id.to_s+" du "+@course.date_when.to_s+" a été modifiée.", ['admins', 'partneradmins'], admin_course_path(@course))

			if @course.need_review? then Notification::make('warning', 'Course à valider', "La course n°"+ @course.id.to_s+" du "+@course.date_when.to_s+" a besoin d'être validée.", ['admins'], admin_course_path(@course)) end

			redirect_to admin_course_path(@course)
		else
			flash[:error] = "La course n'a pas pu être modifiée, veuillez réessayer :"
			AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_updated', 'target_object' => {'type' => 'course', 'id' => @course.id.to_s} })
			render 'edit'
		end
	end
	def destroy
		if @course.destroy
		    flash[:success] = "Course supprimée."
		    Log.create(user_id: current_user.id, target_type: 1, target_id: @course.id, action: 'destroy')
		    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'course', 'id' => params[:id].to_s} })
		    redirect_to admin_courses_path
		end
	end

		private

		    def course_params
		    	params['course']['stops'] = params['course']['stops'].to_json
		    	params.require(:course).permit(:from, :to, :date_when, :time_when, :computed_distance, :computed_duration, :computed_price, :stops_price, :promocode_amount, :commission, :stops, :nb_people, :nb_luggage, :user_id, :partner_id, :car_id, :company_id, :status, :notes, :car_type, :created_by, :company_id, :promocode_id, :driver_id, :payment_when, :payment_by, :payment_status, :payment_type, :flight_number, :need_review)
		    end

			def check_privileges
				if userWeight <= User::Account_types[:admin][:weight]
					@course = Course.find_by(id: params[:id])
				else
					@course = current_partner.courses.find_by(id: params[:id])
				end

				if @course.nil?
					flash[:error] = "Page inaccessible."
					redirect_to [:admin, 'home'] 
				end
			end

			def protect_destroy
				if userWeight < User::Account_types[:superadmin][:weight]
					flash[:error] = "Page inaccessible."
					redirect_to [:admin, 'home'] 
				end
			end

end
