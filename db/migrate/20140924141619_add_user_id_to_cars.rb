class AddUserIdToCars < ActiveRecord::Migration
  def change
  	add_column :users, :id_partner, :integer
  	add_column :users, :created_by, :integer
  end
end
