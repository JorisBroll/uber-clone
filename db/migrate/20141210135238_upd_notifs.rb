class UpdNotifs < ActiveRecord::Migration
  def change
  	add_column :notifications, :link, :string
  	add_column :notifications, :seen_at, :datetime
  end
end
