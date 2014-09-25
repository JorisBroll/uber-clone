class RetaperLesFails < ActiveRecord::Migration
  def change
  	add_column :users, :partner_id, :integer
  	remove_column :users, :id_partner
  end
end
