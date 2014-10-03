class CleanTables2 < ActiveRecord::Migration
  def change
  	add_column :promocodes, :code, :string
  	add_column :cars, :user_id, :integer
  	add_column :users, :position, :string
  	add_column :courses, :done, :boolean, default:false
  	add_column :partners, :company_code, :string
  end
end
