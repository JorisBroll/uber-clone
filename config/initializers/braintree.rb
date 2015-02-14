Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV["BRAINTREE_MERCHANT_ID_SB"]
Braintree::Configuration.public_key = ENV["BRAINTREE_PUBLIC_KEY_SB"]
Braintree::Configuration.private_key = ENV["BRAINTREE_PRIVATE_KEY_SB"]