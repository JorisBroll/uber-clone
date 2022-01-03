class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :from
      t.string :to
      t.datetime :when
      t.integer :user_id
      t.integer :partner_id
      t.integer :car_id

      t.timestamps
    end
  end
end
