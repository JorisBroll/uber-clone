class Updcourses6 < ActiveRecord::Migration
  def change
  	add_column :courses, :driver_id, :integer
  end
end
