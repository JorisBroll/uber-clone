class UpdtUsers < ActiveRecord::Migration
  def change
  	add_column :users, :status, :integer
  	add_column :users, :enabled, :boolean, default: true
  end
end
