class Admin::PaymentsController < ApplicationController
	before_action -> { requiredWeight User::Account_types[:superadmin][:weight] }

	def index
		@payments = Payment.all.order('created_at DESC')

		sdd = SEPA::DirectDebit.new(
		  # Name of the initiating party and creditor
		  # String, max. 70 char
		  name:       'NAVECO SARL',

		  # String, 8 or 11 char
		  bic:        'BNPAFRPPVBE',

		  # String, max. 34 chars
		  iban:       'FR7630004014210001009240362',

		  # Creditor Identifier
		  # String, max. 35 chars
		  creditor_identifier: 'DE98ZZZ09999999999'
		)

		sdd.add_transaction(
		  # Name of the debtor
		  # String, max. 70 char
		  name: 'HALIM AMIRA',

		  # International Bank Account Number of the debtor's account
		  # String, max. 34 chars
		  iban: 'DE21500500009876543210',

		  # Amount in EUR
		  # Number with two decimal digit
		  amount: 10,

		  # OPTIONAL: Instruction Identification, will not be submitted to the debtor
		  # String, max. 35 char
		  instruction: 'TEST',

		  # OPTIONAL: End-To-End-Identification, will be submitted to the debtor
		  # String, max. 35 char
		  reference: 'XYZ/2013-08-ABO/6789',

		  # OPTIONAL: Unstructured remittance information
		  # String, max. 140 char
		  remittance_information: 'Merci de votre confiance !',

		  # String, max. 35 char
		  mandate_id: 'K-02-2011-12345',

		  # Mandate Date of signature
		  # Date
		  mandate_date_of_signature: DateTime.now.to_date,

		  # Shit we don't mess with
		  local_instrument: 'CORE',
		  sequence_type: 'OOFF',
		  batch_booking: false
		)

		# Last: create XML string
		@xml_string = sdd.to_xml('pain.008.001.02') # Use former schema pain.008.002.02
	end
	def new
		@payment = Payment.new()
	end
	def create
		@payment = Payment.new(payment_params)
		if @payment.save
			flash[:success] = "Le paiement numéro "+@payment.id.to_s+" a été crée."
			#AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			redirect_to admin_payments_path
		else
			flash[:error] = "Le paiement n'a pas pu être crée."
			#AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_created', 'target_object' => {'type' => 'promocode'} })
			render 'new'
	    end
	end
	def edit
		@payment = Payment.find(params[:id])
	end
	def update
		@payment = Payment.find(params[:id])
		if @payment.update_attributes(payment_params)
			flash[:success] = "Le paiement numéro "+@payment.id.to_s+" a été modifié avec succès."
			#AppLogger.log ({'user_id' => @current_user, 'action' => 'updated', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			redirect_to admin_payment_path(@payment)
		else
			flash[:error] = "Le paiement n'a pas pu être modifié."
			#AppLogger.log ({'user_id' => @current_user, 'action' => 'fail_updated', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			render 'edit'
		end
	end
	def destroy
	    Payment.find(params[:id]).destroy
	    flash[:success] = "Paiement supprimé. Tous les totaux ont automatiquement ajustés."
	    #AppLogger.log ({'user_id' => @current_user, 'action' => 'deleted', 'target_object' => {'type' => 'promocode', 'id' => params[:id].to_s} })
	    redirect_to admin_payments_path
	end

		private

		    def payment_params
		    	params.require(:payment).permit(:to_type, :to_id, :amount, :notes, :method, :created_at)
		    end
end
