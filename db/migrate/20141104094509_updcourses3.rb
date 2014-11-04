class Updcourses3 < ActiveRecord::Migration
  def change
  	remove_column :courses, :paid_by__id
  	remove_column :courses, :paid_by__type
  	add_column :courses, :payment_by, :integer, default: 0
  end
end
