class UpdCourses10 < ActiveRecord::Migration
  def change
  	add_column :courses, :course_type, :integer, default: 0
  	add_column :courses, :cancel_reason, :string
  end
end
