class ApplicationController < ActionController::Base
  include SubstructApplicationController  
  before_filter :set_substruct_view_defaults
  before_filter :get_nav_tags
  before_filter :find_customer
end