class UpdCars < ActiveRecord::Migration
  def change
  	add_column :cars, :last_selected, :datetime
  	add_column :cars, :driven_by, :integer
  end
end
