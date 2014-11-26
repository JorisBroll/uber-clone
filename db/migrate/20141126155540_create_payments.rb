class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
    	t.string :to_type
    	t.integer :to_id
      	t.integer :amount
      	t.text :notes
      	t.string :method
		t.timestamps
    end
  end
end
