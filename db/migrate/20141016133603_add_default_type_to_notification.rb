class AddDefaultTypeToNotification < ActiveRecord::Migration
  def change
  	change_column :notifications, :notif_type, :integer, :default => 0
  end
end
