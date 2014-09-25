class RenameIdPartnerToCars < ActiveRecord::Migration
  def change
  	rename_column :cars, :id_partner, :partner_id
  end
end
