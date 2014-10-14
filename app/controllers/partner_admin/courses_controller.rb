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

		private

		    def course_params
		    	params.require(:course).permit(:from, :to, :when)
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
