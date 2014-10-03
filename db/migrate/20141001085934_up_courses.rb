class UpCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :nb_people, :integer
  	add_column :courses, :status, :integer
  	add_column :courses, :computed_distance, :float
  	add_column :courses, :computed_price, :float
  	add_column :courses, :stops, :json
  	remove_column :courses, :done
  	add_column :courses, :created_by, :integer
  	add_column :users, :company_id, :integer
  end
end
