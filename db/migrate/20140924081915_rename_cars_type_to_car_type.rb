class RenameCarsTypeToCarType < ActiveRecord::Migration
  def change
  	rename_column :cars, :type, :car_type
  end
end
