class Updcourses < ActiveRecord::Migration
  def change
  	remove_column :courses, :paid
  	add_column :courses, :payment_status, :integer, default: 0
  end
end
