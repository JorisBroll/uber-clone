class Coursefields < ActiveRecord::Migration
  def change
  	add_column :courses, :payment_when, :integer, default: 0
  	add_column :courses, :paid, :boolean, default: false
  	add_column :courses, :paid_when, :datetime
  	add_column :courses, :paid_by__type, :string
  	add_column :courses, :paid_by__id, :integer
  end
end
