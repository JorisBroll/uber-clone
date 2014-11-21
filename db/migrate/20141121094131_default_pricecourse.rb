class DefaultPricecourse < ActiveRecord::Migration
  def change
  	remove_column :courses, :computed_price
  	add_column :courses, :computed_price, :integer, default: 0
  end
end
