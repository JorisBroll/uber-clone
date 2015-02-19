class UpdCourses11 < ActiveRecord::Migration
  def change
  	add_column :courses, :trip_waited, :integer
  end
end
