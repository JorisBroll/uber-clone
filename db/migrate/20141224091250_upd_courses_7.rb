class UpdCourses7 < ActiveRecord::Migration
  def change
  	add_column :courses, :final_price, :float
  	add_column :courses, :damage_price, :integer
  	add_column :courses, :stops_price, :integer
  	change_column :courses, :commission, :float, default: 24.2
  end
end
