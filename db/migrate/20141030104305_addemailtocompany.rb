class Addemailtocompany < ActiveRecord::Migration
  def change
  	add_column :companies, :email, :string
  	add_column :companies, :phone, :string
  	execute 'ALTER TABLE partners ALTER COLUMN status TYPE integer USING (status::integer)'
  end
end
