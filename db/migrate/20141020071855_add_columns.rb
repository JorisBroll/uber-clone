class AddColumns < ActiveRecord::Migration
  def change
  	add_column :users, :last_name, :string
  	add_column :courses, :notes, :text
  	add_column :users, :address, :string
  end
end
