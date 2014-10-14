class Addphotos < ActiveRecord::Migration
  def change
  	add_column :users, :photo, :string
  	add_column :partners, :logo, :string
  	add_column :cars, :photo, :string
  end
end
