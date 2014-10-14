class ChangePositionFormat < ActiveRecord::Migration
  def change
  	add_column :users, :pos_lat, :string
  	add_column :users, :pos_lon, :string
  	remove_column :users, :position
  end
end
