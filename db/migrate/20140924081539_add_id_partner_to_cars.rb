class AddIdPartnerToCars < ActiveRecord::Migration
  def change
    add_column :cars, :id_partner, :integer
  end
end
