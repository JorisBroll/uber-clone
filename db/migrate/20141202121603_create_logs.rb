class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      	t.integer :user_id
    	t.integer :target_type
    	t.integer :target_id
      	t.string :action
      	t.string :extra
		t.timestamps
    end
  end
end
