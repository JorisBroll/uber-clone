class Updcourses5 < ActiveRecord::Migration
  def change
  	add_column :courses, :car_type, :integer, default: 0
  end
end
