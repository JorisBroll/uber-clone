class AddPaymentMethodToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :payment_type, :integer, default: 0
  end
end
