# Handles preferences setting.
#
# - Shipping price matrix
# [FUTURE]
# - Enabling live shipping calc via fedex
# - Enter Authorize.net / payment gateway info
# - Select if we should show order confirmation page or not
#
class Admin::PreferencesController < Admin::BaseController
  verify :method => :post, 
    :only => [:save_prefs], 
    :redirect_to => {:action => :index}
  
  # Handles setting of preferences.
  #
  #
  def index
    set_title('General Preferences')
    # Key prefs into hash based on name
    @prefs = {}
    Preference.find(:all).each do |p|
      @prefs[p.name] = p
    end
  end
  
  def save_prefs
    # Have to do a translation for 'home country', just because of how
    # the select list is structured. Shitty, but it works...
    params[:prefs][:store_home_country] = params[:prefs][:store_home_country][:country_id]
    
    Preference.save_settings(params[:prefs])

    flash[:notice] = "Preferences have been saved."
    
    begin
      Preference.init_mail_settings()
    rescue
      flash[:notice] = "There was an error initializing your mail server settings."
      flash[:notice] << "Please re-check your settings and save again."
    end

    redirect_to :action => 'index' and return
  end

  # SHIPPING METHODS ==========================================================

  # Defines shipping prices and matrix.
  #
  # Also saves shipping prices.
  #
  def shipping
    set_title('Shipping rates')
    @shipping_types = OrderShippingType.find(:all)
  end
  def save_shipping
    # Index is the shipping type ID.
    if params[:shipping_types]
      params[:shipping_types].each do |id,type_attributes|
        type = OrderShippingType.find(id)
        type.update_attributes(type_attributes)
      end
      flash[:notice] = "Shipping rates updated."
    end
    redirect_to :action => 'shipping'
  end
  def add_new_rate_ajax
    shipping_type = OrderShippingType.create(params[:shipping_type])
    render(:partial => 'shipping_type', :locals => {:shipping_type => shipping_type})
  end
  def remove_shipping_type_ajax
    @type = OrderShippingType.find(
      :first,
      :conditions => ["id = ?", params[:id]]
    )
    @type.destroy if @type
    # Render nothing to denote success
    render :text => ""
  end
  # Simply renders the weight variation ajax partial.
  # Gets passed container to render into.
	def add_shipping_variation_ajax
	  @variation = OrderShippingWeight.new
	  # Set random ID so that we can reference things from JS...
	  @variation.id = Time.now.to_i
	  render(:update) do |page| 
	    page.insert_html(
	      :bottom, 
	      "variations_#{params[:id]}", 
	      :partial => 'shipping_variation', 
	      :locals => { 
	        :shipping_variation => @variation,
	        :sid => params[:id]
	      }
	    )
	  end
  end
	# Called for actually removing a weight variation if found, or just returns
	# nothing.
	#
	# This gets called for removing actual variations, and removing variations
	# that haven't been saved yet.
	#
	def remove_shipping_variation_ajax
	  @v = OrderShippingWeight.find(:first, :conditions => ["id = ?", params[:id]])
	  @v.destroy if @v
	  render :nothing => 'true'
  end
  
  
  #############################################################################
  # PREFERENCES
  #############################################################################
  
  private
  
    # Set title, appends "Prefs: " to it...
    #
    def set_title(title)
      @title = "#{title}"
    end

end
