class UpdUsers5FbId < ActiveRecord::Migration
  def change
  	add_column :users, :facebookID, :string
  end
end
