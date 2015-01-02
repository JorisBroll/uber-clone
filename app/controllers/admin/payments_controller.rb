class Admin::PaymentsController < ApplicationController
	before_action :admins_only

	def index
		@payments = Payment.all.order('created_at DESC')
	end
	def new
		@payment = Payment.new()
	end
	def create
		@payment = Payment.new(payment_params)
		if @payment.save
			flash[:success] = "Le paiement numéro "+@payment.id.to_s+" a été crée."
			#AppLogger.log ({'user_id' => @current_user, 'action' => 'created', 'target_object' => {'type' => 'promocode', 'id' => @promocode.id.to_s} })
			redirect_to admin_payment_path(@payment)
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
