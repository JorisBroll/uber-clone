class AddPhones < ActiveRecord::Migration
  def change
  	add_column :users, :phone, :string
  	add_column :partners, :phone, :string
  end
end
