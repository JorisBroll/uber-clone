class UpdTables2 < ActiveRecord::Migration
  def change
  	add_column :users, :city, :string
  	add_column :users, :cellphone, :string
  	add_column :companies, :city, :string
  	add_column :companies, :company_code, :string
  	add_column :companies, :tva_number, :string
  	add_column :companies, :bookmanager, :string
  	add_column :partners, :city, :string
  	add_column :partners, :status, :string
  	add_column :partners, :tva_number, :string
  	add_column :cars, :brand, :string
  	add_column :cars, :model, :string
  	add_column :cars, :color, :string
  	add_column :cars, :plate_number, :string
  	add_column :courses, :nb_luggage, :integer
  end
end
