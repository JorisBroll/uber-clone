class Updcourses4 < ActiveRecord::Migration
  def change
  	add_column :courses, :rating_client, :integer
  	add_column :courses, :rating_partner, :integer
  	add_column :courses, :trip_started, :datetime
  	add_column :courses, :trip_finished, :datetime
  	add_column :courses, :trip_feedback, :text
  	add_column :courses, :commission, :integer, default: 20
  end
end
