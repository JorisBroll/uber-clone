class UpdCourseDefaults2 < ActiveRecord::Migration
  def change
  	change_column :courses, :promocode_amount, :float, default: 0
  end
end
