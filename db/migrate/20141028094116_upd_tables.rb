class UpdTables < ActiveRecord::Migration
  def change
	add_column :users, :postcode, :string
	add_column :partners, :address, :string
	add_column :partners, :postcode, :string
	add_column :courses, :flight_number, :string
	add_column :companies, :address, :string
	add_column :companies, :postcode, :string
	add_column :users, :promocode_id, :integer, default: 0
	change_column :users, :promocode_id, :integer, default: 0
	change_column :cars, :user_id, :integer, default: 0
	change_column :courses, :user_id, :integer, default: 0
	change_column :courses, :partner_id, :integer, default: 0
	change_column :courses, :car_id, :integer, default: 0
	change_column :courses, :nb_people, :integer, default: 1
	change_column :courses, :created_by, :integer, default: 0
	change_column :notifications, :user_id, :integer, default: 0
	change_column :promocodes, :effect_type, :integer, default: 0
	change_column :promocodes, :effect_length, :integer, default: 0
	change_column :users, :created_by, :integer, default: 0
	change_column :users, :partner_id, :integer, default: 0
	change_column :users, :company_id, :integer, default: 0
  end
end
