class AddComputedTime < ActiveRecord::Migration
  def change
  	add_column :courses, :computed_time, :string
  end
end
