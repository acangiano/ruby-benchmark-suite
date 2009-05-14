module SubstructApplicationController
  include Substruct
  include LoginSystem
  require 'substruct_deprecated'

  def self.included(base)
    base.class_eval do
      def cache
        $cache ||= SimpleCache.new 1.hour
      end
    end
  end
  
  def set_substruct_view_defaults
    # TODO - Clean up this messy navigation generation stuff...
  	@cname = self.controller_name
  	@aname = self.action_name
  	# Special handling for the home page...
  	if (@cname == 'content_nodes' && @aname == 'show_by_name' && params[:name] == 'home') then
  		@cname = 'main'
  	end
  	@store_name = Preference.find_by_name('store_name').value rescue 'Substruct'
  	# Is this a blog post?
  	@blog_post = false
  	if (@cname == 'content_nodes' && @content_node) then
  		if (@content_node.is_blog_post?) then
  			@blog_post = true
  		end
  	end
  end
  
  # Gets navigation tags for our renderer.
  # Also lets us know if we're in one of our nav tags so
  # we can display the proper header.
  #
  def get_nav_tags
    @main_nav_tags = Tag.find_ordered_parents
  end
  
  # Finds customer if they're logged in or not.
  def find_customer
    @customer = OrderUser.find_by_id(session[:customer])
  end

  # Switches to UTF8 charset
  #
  def configure_charsets
    content_type = headers["Content-Type"] || 'text/html'
    if /^text\//.match(content_type)
      headers["Content-Type"] = "#{content_type}; charset=utf-8" 
    end
    ActiveRecord::Base.connection.execute 'SET NAMES UTF8'
  end
  
  # Requres SSL for specified actions.
  #
  def ssl_required
    if ENV['RAILS_ENV'] == "production" && Substruct.override_ssl_production_mode == false
      if !request.ssl?
        redirect_to "https://" + request.host + request.request_uri
        flash.keep
        return false
      end
    end
  end
  
  # Used in StoreController and CustomerController
  #  
  def log_customer_in(customer)
    session[:customer] = customer.id
  end

end
