class UpdCourses12 < ActiveRecord::Migration
  def change
  	remove_column :courses, :trip_waited
  	add_column :courses, :trip_wait_start, :datetime
  end
end
