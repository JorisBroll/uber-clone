class RenameCarsClassToType < ActiveRecord::Migration
  def change
  	rename_column :cars, :class, :type
  end
end
