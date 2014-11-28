class PaymentMethod < ActiveRecord::Migration
  def change
  	remove_column :payments, :method
  	add_column :payments, :method, :integer, default: 0
  end
end
