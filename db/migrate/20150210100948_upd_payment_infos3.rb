class UpdPaymentInfos3 < ActiveRecord::Migration
  def change
  	add_column :payment_infos, :paypal_card_ending, :string
  end
end
