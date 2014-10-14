class ChangeGeolocationVariablesTypes < ActiveRecord::Migration
  def change
  	change_column :users, :pos_lat, 'decimal USING CAST(pos_lat AS decimal)'
  	change_column :users, :pos_lon, 'decimal USING CAST(pos_lon AS decimal)'
  end
end
