class UpdCourses9 < ActiveRecord::Migration
  def change
  	add_column :courses, :rejected_by, :json
  end
end
