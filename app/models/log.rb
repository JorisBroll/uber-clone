class Log < ActiveRecord::Base
	enum target_type: AppTools.objects.collect { |key, o| key }
end
