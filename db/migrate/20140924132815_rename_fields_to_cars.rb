class RenameFieldsToCars < ActiveRecord::Migration
  def change
  	remove_column :cars, :car_type
  	rename_column :cars, :car_typez, :car_type
  end
end
