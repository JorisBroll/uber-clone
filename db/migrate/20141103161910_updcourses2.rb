class Updcourses2 < ActiveRecord::Migration
  def change
  	add_column :courses, :promocode_id, :integer
  end
end
