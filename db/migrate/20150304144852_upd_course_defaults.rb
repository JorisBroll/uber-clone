class UpdCourseDefaults < ActiveRecord::Migration
  def change
  	change_column :courses, :final_price, :float, default: 0
  	change_column :courses, :stops_price, :integer, default: 0
  	change_column :courses, :damage_price, :integer, default: 0
  end
end
