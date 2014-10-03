class Admin::CoursesController < ApplicationController
	before_action :superadmins_only

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
			redirect_to admin_courses_path
	    else
	    	flash[:error] = "La course n'a pas pu être créée, veuillez réessayer :"
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
			redirect_to admin_courses_path
		else
			flash[:error] = "La course n'a pas pu être modifiée, veuillez réessayer :"
			render 'edit'
		end
	end

		private

		    def course_params
		    	params['course']['stops'] = params['course']['stops'].to_json
		    	params.require(:course).permit(:from, :to, :date_when, :time_when, :stops, :user_id, :partner_id, :status)
		    end

end
