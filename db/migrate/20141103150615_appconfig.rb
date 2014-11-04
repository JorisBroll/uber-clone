class Appconfig < ActiveRecord::Migration
  	create_table :app_configs do |t|
      t.string :course_margin
    end
end
