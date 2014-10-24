class AddTypeToNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :notif_type, :integer
  end
end
