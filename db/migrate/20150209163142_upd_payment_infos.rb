class UpdPaymentInfos < ActiveRecord::Migration
  def change
  	remove_column :users, :access_token
  	remove_column :users, :refresh_token
  	add_column :users, :selected_payment, :integer

  	remove_column :payment_infos, :card_number
    remove_column :payment_infos, :card_expiration_month
    remove_column :payment_infos, :card_expiration_year
    remove_column :payment_infos, :card_verification
    remove_column :payment_infos, :card_ending_code

    add_column :payment_infos, :paypal_card_id, :string
    add_column :payment_infos, :paypal_access_token, :string
    add_column :payment_infos, :paypal_refresh_token, :string
  end
end
