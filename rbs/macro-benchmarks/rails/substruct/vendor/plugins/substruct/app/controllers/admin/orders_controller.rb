class Admin::OrdersController < Admin::BaseController
  layout 'admin'
  include OrderHelper
  include Pagination
  
  @@list_options = [
    "Ready To Ship",
    "On Hold",
    "Completed",
    "All"
  ]

  # Index page when you hit /admin
  #
  # Right now just listing orders.
  def index
    list
    render :action => 'list'
  end

  # Lists orders in the system.
  #
  # Can list multiple ways. (see @@list_options above)
  #
  def list
    # Clone so we can modify the list options if we want
    @list_options = @@list_options.clone

    if params[:key] then
      @viewing_by = params[:key]
    elsif session[:last_order_list_view] then
      @viewing_by = session[:last_order_list_view]
    else
      @viewing_by = @list_options[0]
    end

    @title = "Order List"

    conditions = nil

    case @viewing_by
      when @list_options[0]
        conditions = 'order_status_code_id = 5'
      when @list_options[1]
        conditions = 'order_status_code_id = 3
                      OR order_status_code_id = 4'
      when @list_options[2]
        conditions = 'order_status_code_id = 5
                      OR order_status_code_id = 6
                      OR order_status_code_id = 7'
      when @list_options[3]
        conditions = nil
    end

    session[:last_order_list_view] = @viewing_by

    @orders = Order.paginate(
      :order => 'created_on DESC',
      :conditions => conditions,
      :page => params[:page],
      :per_page => 30
    )
  end

  # Searches orders by order #, first and last name.
  #
  # Search uses the list view as well.
  # We create a custom paginator to show search results since there might be a ton
  #
  def search
    setup_search(params)

    # Paginate that will work with will_paginate...yee!
    per_page = 30
    list = Order.search(@search_term)
    @search_count = list.size
    pager = Paginator.new(list, list.size, per_page, params[:page])
    @orders = returning WillPaginate::Collection.new(params[:page] || 1, per_page, list.size) do |p|
      p.replace list[pager.current.offset, pager.items_per_page]
    end

    render :action => 'list' and return
  end
  
  # Searches orders by email.
  #
  # Tried adding email into the original search but it was just _too_slow_.
  #
  # Added it here instead
  #
  def search_by_email
    setup_search(params)
    @orders = Order.paginate(
      :order => "orders.created_on DESC",
      :conditions => ['order_users.email_address LIKE ?', "%#{@search_term}%"],
      :include => :order_user,
      :page => params[:page],
      :per_page => 30
    )
    
    render :action => 'list' and return
  end
  
  # Searches orders via the notes field.
  #
  #
  def search_by_notes
    setup_search(params)
    @orders = Order.paginate(
      :order => "orders.created_on DESC",
      :conditions => ['notes LIKE ?', "%#{@search_term}%"],
      :include => :order_user,
      :page => params[:page],
      :per_page => 30
    )
              
    render :action => 'list' and return
  end

  # Shows sales totals for all years.
  #
  def totals
    @title = 'Sales Totals'
    sql = "SELECT DISTINCT YEAR(created_on) as year "
    sql << "FROM orders "
    sql << "ORDER BY year ASC"
    @year_rows = Order.find_by_sql(sql)
    @years = Hash.new
    # Build a hash containing all orders hashed by year.
    for row in @year_rows
      @years[row.year] = Order.get_totals_for_year(row.year)
    end
  end
  
  # Lists number orders by country
  #
  def by_country
    @title = "Orders By Country"
    
    @countries = Country.find(:all)
    # Remove countries with 0 orders
    @countries.reject! { |c| c.number_of_orders == 0 }
    # Sort by number of orders
    @countries.sort! { |x, y| y.number_of_orders <=> x.number_of_orders }
  end

  # Shows orders for a particular country
  #
  def for_country
    @country = Country.find_by_id(params[:id])
    
    if !@country
      flash[:notice] = "No country found for the URL you entered."
      redirect_to :action => 'by_country' and return
    end
    
    # Need this so that links show up
    @list_options = @@list_options
    @title = "Orders for #{@country.name}"
    
    # Paginate that will work with will_paginate...yee!
    per_page = 30
    list = Order.find_by_country(@country.id)
    @order_count = list.size
    pager = Paginator.new(list, list.size, per_page, params[:page])
    @orders = returning WillPaginate::Collection.new(params[:page] || 1, per_page, list.size) do |p|
      p.replace list[pager.current.offset, pager.items_per_page]
    end
    
    render :action => 'list' and return
  end

  # Edits or shows an existing order
  #
  #
  def show
    @order = Order.find(params[:id])
    order_time = @order.created_on.strftime("%m/%d/%y %I:%M %p")
    @title = "Order #{@order.order_number} - #{order_time}"
    @order_user = @order.order_user || OrderUser.new
    @order_account = @order_user.order_account || OrderAccount.new
    @billing_address = @order.billing_address || OrderAddress.new
    @shipping_address = @order.shipping_address || OrderAddress.new
    if @shipping_address == @billing_address then
      @use_separate_shipping_address = false
    else
      @use_separate_shipping_address = true
    end
    @shipping_address = OrderAddress.new if !@shipping_address
    logger.info "\n\n SHIPPING ADDRESS:\n #{@shipping_address.inspect}\n"
    logger.info @use_separate_shipping_address
    
    # Find all products not included as a order line item already.
    @products = Item.find(
      :all,
      :conditions => [
        "id NOT IN(?)", 
        @order.order_line_items.collect {|i| i.item_id}.join(',')
      ]
    )
    # If this order is "finished" send them to the view page instead of the edit one...
		# Orders on the show page can still do things like add notes.
    if (@order.order_status_code.is_editable?) then
      render :action => 'edit' and return
    else
      render :action => 'show' and return
    end
  end

  # Updates an order from edit
  #
  #
  def update
		@order = Order.find(params[:id])

    begin
  		update_order_from_post
      flash[:notice] = 'Order was successfully updated.'
      redirect_to :action => 'show', :id => @order.id
    rescue
      @products = Product.find(:all)
  	  if !@use_separate_shipping_address && @shipping_address.nil?
  		  @shipping_address = @order.shipping_address
  		else
  		  @shipping_address = OrderAddress.new
  	  end
  		logger.info "BILLING ADDRESS: \n#{@billing_address}"
  		logger.info "SHIPPING ADDRESS: \n#{@shipping_address}"
			flash.now[:notice] = 'There were problems modifying the order. Please check the fields below.'
      render :action => 'edit' and return
    end
  end

	# Voids an order
	#
	# THIS HAS BEEN REMOVED UNTIL WE CAN RECODE USING ACTIVEMERCHANT
	def void
	end

	# Marks an order as returned.
	# Useful for closed orders.
	def return_order
		@order = Order.find(params[:id])
		@order.order_status_code_id = 9
		@order.save
		flash[:notice] = "Order has been marked as returned."
		redirect_to :action => 'show', :id => @order.id
	end

  # Resends the order receipt to the customer
  def resend_receipt
    @order = Order.find(params[:id])
   	#@order.cleanup_successful
    # Send success message
    @order.deliver_receipt
    redirect_to :action => 'show', :id => @order.id
  end

  # Deletes an order
  def destroy
    Order.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  # Processes orders passed in, packages as XML or CSV and downloads
  #
  def download
    @orders = Order.find(params[:ids])
    
    case params[:format]
      when 'xml'
        content = Order.get_xml_for_orders(@orders)
      when 'csv'
        content = Order.get_csv_for_orders(@orders)
    end
    
    directory = File.join(RAILS_ROOT, "public/system/order_files")
    file_name = Time.now.strftime("%m_%d_%Y_%H-%M")
    file = "#{file_name}.#{params[:format]}"
    save_to = "#{directory}/#{file}"
    
    # make sure we have the directory to write these files to
    if Dir[directory].empty?
      FileUtils.mkdir_p(directory)
    end    
    
    # write the file
    File.open(save_to, "w") { |f| f.write(content)  }
    
    send_file(save_to, :type => "text/#{params[:format]}")
  end
  
  # PRIVATE METHODS ===========================================================
  private
    # Sets up search term and stores session variables.
    #
    # Used from all 3 search methods.
    #
    def setup_search(params)
      @search_term = params[:term]

      if !@search_term then
        @search_term = session[:last_search_term]
      end
      # Save this for after editing
      session[:last_view] = 'search'
      session[:last_search_term] = @search_term
      
      # Need this so that links show up
      @list_options = @@list_options
      @title = "Search Results"
      @search_title =  "You Searched For '#{@search_term}'"
    end

end
