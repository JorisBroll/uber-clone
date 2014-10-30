class PartnerAdmin::CoursesController < ApplicationController
	before_action :partneradmins_only

	def index
		@courses = current_partner.courses.all
	end
	def show
		@course = get_correct_course
	end
	def new
		@course = current_partner.courses.build
	end
	def create
		@course = current_partner.courses.build(course_params)
		if @course.save
			flash[:success] = "La course n°"+@course.id.to_s+" a été créée."
			redirect_to partner_admin_courses_path(@partner)
	    else
	    	flash[:error] = "La course n'a pas pu être créée, veuillez réessayer :"
	    	render 'new'
	    end
	end
	def edit
		@course = get_correct_course
	end
	def update
		@course = get_correct_course
		if @course.update_attributes(course_params)
			flash[:success] = "La course n°"+@course.id.to_s+" a été modifiée avec succès."
			redirect_to partner_admin_courses_path
		else
			flash[:error] = "La course n'a pas pu être modifiée, veuillez réessayer :"
			render 'edit'
		end
	end
	def destroy
		@course = Course.find(params[:id]).destroy
	    flash[:success] = "Course supprimée."
	    AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'course', 'id' => params[:id].to_s} })
	    redirect_to partner_admin_courses_path
	end

		private

		    def course_params
		    	params['course']['stops'] = params['course']['stops'].to_json
		    	params.require(:course).permit(:from, :to, :date_when, :time_when, :computed_distance, :computed_duration, :computed_price, :stops, :nb_people, :nb_luggage, :user_id, :partner_id, :car_id, :company_id, :status, :notes, :payment_when, :created_by, :company_id, :payment_type, :flight_number)
		    end

		    def get_correct_course # Make sure we don't get an outside course
				if !current_partner.courses.find_by(id: params[:id]).nil?
					return current_partner.courses.find(params[:id])
				else
					flash[:error] = "Aucune course trouvée."
					redirect_to partner_admin_courses_path
				end
	        end
end
