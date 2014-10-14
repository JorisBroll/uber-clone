class AddComputedDuration < ActiveRecord::Migration
  def change
  	rename_column :courses, :computed_time, :computed_duration
  end
end
