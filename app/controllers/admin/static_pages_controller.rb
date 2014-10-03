class Admin::StaticPagesController < ApplicationController
	before_action :superadmins_only
	
	def home
	    @users = User.all
	end

	def logout_partner
	    sign_out_partner
	    redirect_to admin_home_path
	end

end
