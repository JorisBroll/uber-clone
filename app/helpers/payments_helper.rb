module PaymentsHelper
	def methods_for_select
		@table = Payment::Methods.collect { |i, o| [o[:name], i] }
	end
end
