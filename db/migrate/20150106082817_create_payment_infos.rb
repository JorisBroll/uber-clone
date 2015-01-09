class CreatePaymentInfos < ActiveRecord::Migration
  def change
    create_table :payment_infos do |t|
    	t.integer :infos_type
    	t.integer :user_id
		t.string :card_number
		t.string :card_expiration_month
		t.string :card_expiration_year
		t.string :card_verification
		t.string :card_ending_code
		t.string :paypal_email
		t.string :paypal_token
    end
  end
end
