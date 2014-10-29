class AddcreatedbyCompanies < ActiveRecord::Migration
  def change
  	add_column :companies, :partner_id, :integer
  end
end
