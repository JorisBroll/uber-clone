class UpdCourses8 < ActiveRecord::Migration
  def change
  	add_column :courses, :promocode_amount, :float
  end
end
