class Currentpromocode < ActiveRecord::Migration
  def change
  	add_column :users, :selected_promocode, :integer
  end
end
