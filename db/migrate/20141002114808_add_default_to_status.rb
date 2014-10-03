class AddDefaultToStatus < ActiveRecord::Migration
  def change
  	change_column :courses, :status, :integer, :default => 0
  end
end
