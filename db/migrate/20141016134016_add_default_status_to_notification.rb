class AddDefaultStatusToNotification < ActiveRecord::Migration
  def change
  	change_column :notifications, :seen, :boolean, :default => false
  end
end
