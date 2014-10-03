class CreatePromocodes < ActiveRecord::Migration
  def change
    create_table :promocodes do |t|
      t.string :name
      t.integer :effect
      t.integer :effect_length
      t.integer :effect_strengh

      t.timestamps
    end
  end
end
