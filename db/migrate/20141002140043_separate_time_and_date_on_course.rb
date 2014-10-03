class SeparateTimeAndDateOnCourse < ActiveRecord::Migration
  def change
  	remove_column :courses, :when
  	add_column :courses, :date_when, :date
  	add_column :courses, :time_when, :time	
  end
end
