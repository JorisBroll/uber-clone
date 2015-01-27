class UpdCars2 < ActiveRecord::Migration
  def change
  	remove_column :cars, :name
  end
end
