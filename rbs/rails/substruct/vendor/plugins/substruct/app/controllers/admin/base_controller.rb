class Admin::BaseController < ApplicationController
  layout 'admin'
  before_filter :ssl_required
  
	# Check permissions for everything on the admin side.
  before_filter :login_required,
								:except => [:login]
	before_filter :check_authorization, 
								:except => [:login, :index]

end
