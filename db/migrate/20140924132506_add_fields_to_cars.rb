class AddFieldsToCars < ActiveRecord::Migration
  def change
  	add_column :cars, :slots, :integer
  	add_column :cars, :car_typez, :integer, default:0
  end
end
