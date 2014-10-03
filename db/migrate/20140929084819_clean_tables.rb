class CleanTables < ActiveRecord::Migration
  def change
  	rename_column :promocodes, :effect, :effect_type
  	add_column :promocodes, :effect_type_value, :integer
  	rename_column :promocodes, :effect_strengh, :effect_length_value
  	drop_table :sub_companies
  end
end
