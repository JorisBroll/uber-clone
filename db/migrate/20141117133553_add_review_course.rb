class AddReviewCourse < ActiveRecord::Migration
  def change
  	add_column :courses, :need_review, :boolean, default: false
  end
end
