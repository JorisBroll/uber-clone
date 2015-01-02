class UpdUsers3Token < ActiveRecord::Migration
  def change
  	add_column :users, :login_token, :text
  	add_column :users, :login_token_expiration, :datetime
  end
end
