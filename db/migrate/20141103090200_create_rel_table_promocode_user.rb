class CreateRelTablePromocodeUser < ActiveRecord::Migration
  def change
    create_table :promocodes_users, :id => false do |t|
		t.integer :promocode_id
		t.integer :user_id
	end

	add_index :promocodes_users, [:promocode_id, :user_id]
  end
end
