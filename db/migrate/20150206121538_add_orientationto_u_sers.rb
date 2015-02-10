class AddOrientationtoUSers < ActiveRecord::Migration
  def change
  	add_column :users, :pos_deg, :decimal, default: 0
  end
end
