class Adduserfeedback < ActiveRecord::Migration
  def change
  	add_column :courses, :behavior_feedback, :integer
  	add_column :users, :access_token, :string
  	add_column :users, :refresh_token, :string
  end
end
