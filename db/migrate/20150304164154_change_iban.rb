class ChangeIban < ActiveRecord::Migration
  def change
  	remove_column :users, :iban
  	add_column :partners, :iban, :string
  end
end
