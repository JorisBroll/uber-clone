class DropDefaults < ActiveRecord::Migration
  def change
  	change_column :users, :promocode_id, :integer, default: nil
	change_column :cars, :user_id, :integer, default: nil
	change_column :courses, :user_id, :integer, default: 1
	change_column :courses, :partner_id, :integer, default: 1
	change_column :courses, :car_id, :integer, default: nil
	change_column :courses, :created_by, :integer, default: nil
	change_column :notifications, :user_id, :integer, default: nil
	change_column :users, :created_by, :integer, default: nil
	change_column :users, :partner_id, :integer, default: nil
	change_column :users, :company_id, :integer, default: nil
  end
end
