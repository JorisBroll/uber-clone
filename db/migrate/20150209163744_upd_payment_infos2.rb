class UpdPaymentInfos2 < ActiveRecord::Migration
  def change
  	remove_column :payment_infos, :paypal_email
  	remove_column :payment_infos, :paypal_token
  end
end
