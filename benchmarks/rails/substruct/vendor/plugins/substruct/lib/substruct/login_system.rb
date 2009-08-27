module LoginSystem 
  protected
  
  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights  
  # example:
  #
  #  # only allow nonbobs
  #  def authorize?(user)
  #    user.login != "bob"
  #  end
  def authorize?(user)
     true
  end
  
  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  # 
  #  # don't protect the login and the about method
  #  def protect?(action)
  #    if ['action', 'about'].include?(action)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?(action)
    true
  end
   
  # login_required filter. add 
  #
  #   before_filter :login_required
  #
  # if the controller should be under any rights management. 
  # for finer access control you can overwrite
  #   
  #   def authorize?(user)
  # 
  def login_required
    
    if not protect?(action_name)
      return true  
    end

    if session[:user] and authorize?(session[:user])
      return true
    end

    # store current location so that we can 
    # come back after the user logged in
    store_location
  
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
  end

	# Checks authorization of a page
	# This used in conjunction with login_required provides
	# the base for role based access control
	def check_authorization
		user = User.find(session[:user])
		
		for role in user.roles
			for right in role.rights
				# action_name might be multiple actions, CSV
				# split them into an array
				actions = right.actions.split(",")
				#				
				for action in actions
					logger.info("[AUTH] #{right.controller} - #{action}")
					# check against specific action names 
					return true if (action == action_name && right.controller == controller_name)
					# check against wildcard for full controller access
					return true if (action == '*' && right.controller == controller_name)
				end
			end
		end
		 
		flash[:notice] = "You are not allowed to access <i>'#{controller_name}/#{action_name}'</i>.<br/><br/>If you feel this is an error please contact your Substruct admin."
		request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to '/') 
		return false		
	end

  # overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    redirect_to :controller=>"/accounts", :action =>"login"
  end  
  
  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
  end

end
