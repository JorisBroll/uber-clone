class UpdUsers4Sponsoring < ActiveRecord::Migration
  def change
  	add_column :users, :sponsored_by, :integer
  end
end
