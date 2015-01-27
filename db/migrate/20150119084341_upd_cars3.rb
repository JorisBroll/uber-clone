class UpdCars3 < ActiveRecord::Migration
  def change
  	remove_column :cars, :user_id
  end
end
