class Admin::ProductsController < Admin::BaseController
  include Pagination

  before_filter :set_tags

  def index
    list
    render :action => 'list'
  end

	# Lists all products
  def list
    @title = "All Product List"
    @products = Product.paginate(
      :order => "name ASC",
      :page => params[:page],
      :per_page => 30
    )
  end
  
  # Shows all tags in system and lets user list products by tag.
  def list_tags
    
  end

	# Lists products by tag
  def list_by_tags

    @list_options = Tag.find_alpha

    if params[:key] then
      @viewing_by = params[:key]
    elsif session[:last_product_list_view] then
      @viewing_by = session[:last_product_list_view]
    else
      @viewing_by = @list_options[0].id
    end

    @tag = Tag.find(:first, :conditions => ["id=?", @viewing_by])
    if @tag == nil then
			redirect_to :action => 'list'
			return
    end

    @title = "Product List For Tag - '#{@tag.name}'"

    conditions = nil

    session[:last_product_list_view] = @viewing_by


    #@products = @tag.products
    @products = @tag.products.paginate(
      :order => "name ASC",
      :page => params[:page],
      :per_page => 30
    )
    render :action => 'list'
  end

  def new
    @title = "New Product"
		@image = Image.new
    @product = Product.new
  end
  
  def edit
    @title = "Editing A Product"
    @product = Product.find(params[:id])
		@image = Image.new
  end

  # Saves product from new and edit.
  #
  #
  def save
    # If we have ID param this isn't a new product
    if params[:id]
      @new_product = false
      @title = "Editing Product"
      @product = Product.find(params[:id])
    else
      @new_product = true
      @title = "New Product"
      @product = Product.new()
    end
    @product.attributes = params[:product]
		if @product.save
			# Save product tags
			# Our method doesn't save tags properly if the product doesn't already exist.
			# Make sure it gets called after the product has an ID
			@product.tag_ids = params[:product][:tag_ids] if params[:product][:tag_ids]
      # Build product images from upload
      image_errors = []
      unless params[:image].blank?
  			params[:image].each do |i|
          if i[:image_data] && !i[:image_data].blank?
            new_image = Image.new
            logger.info i[:image_data].inspect
            new_image.uploaded_data = i[:image_data]
            if new_image.save
              @product.images << new_image
            else
              image_errors.push(new_image.filename)
            end
          end
        end
      end

      # Build downloads from form
      download_errors = []
      unless params[:download].blank?
  			params[:download].each do |i|
          if i[:download_data] && !i[:download_data].blank?
            new_download = Download.new
            logger.info i[:download_data].inspect
          
            new_download.uploaded_data = i[:download_data]
            if new_download.save
              new_download.product = @product
            else
              download_errors.push(new_download.filename)
            end
          end
        end
      end

      # Build variations from form
      if !params[:variation].blank?
        params[:variation].each do |v|
          variation = @product.variations.find_or_create_by_id(v[:id])
          variation.attributes = v
          variation.save
          @product.variations << variation
        end
      end
      
      flash[:notice] = "Product '#{@product.name}' saved."
      if image_errors.length > 0
        flash[:notice] += "<b>Warning:</b> Failed to upload image(s) #{image_errors.join(',')}. This may happen if the size is greater than the maximum allowed of #{Image::MAX_SIZE / 1024 / 1024} MB!"
      end
      if download_errors.length > 0
        flash[:notice] += "<b>Warning:</b> Failed to upload file(s) #{download_errors.join(',')}."
      end
      redirect_to :action => 'edit', :id => @product.id
    else
			@image = Image.new
			if @new_product
        render :action => 'new' and return
      else
        render :action => 'edit' and return
      end
    end    
  end

  def destroy
    Product.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

	# Search uses the list view as well.
	# We create a custom paginator to show search results since there might be a ton
	def search
	  @search_term = params[:term]

	  if !@search_term then
	    @search_term = session[:last_search_term]
	  end
	  # Save this for after editing
	  session[:last_search_term] = @search_term

	  # Need this so that links show up
	  @title = "Search Results For '#{@search_term}'"

    # Paginate that will work with will_paginate...yee!
    per_page = 30
    list = Product.search(@search_term)
    @search_count = list.size
    pager = Paginator.new(list, list.size, per_page, params[:page])
    @products = returning WillPaginate::Collection.new(params[:page] || 1, per_page, list.size) do |p|
      p.replace list[pager.current.offset, pager.items_per_page]
    end

	  render :action => 'list' and return
	end


	# Called when updating Tags from the product edit page
	# Returns the rendered partial for our Tag list
	def get_tags
		if !params[:id].blank? then
			@product = Product.find(params[:id])
		else
			@product = Product.new
		end
		@partial_name = params[:partial_name]
		render(:partial => @partial_name,
					 :collection => @tags,
					 :locals => {:product => @product})
	end
	
	# Generates javascript for our product suggestion list
	#
	# By default only shows Products, but if passed 'show_all_items'
	# it grabs every item. This case is used in promotions...
	#
	def suggestion_js
	  if params[:show_all_items]
	    @items = Item.find(:all)
    else
		  @items = Product.find(:all)
		end
		headers['content-type'] = 'text/javascript'
		render :layout => false
	end
	
	# AJAX METHODS ==============================================================
	
	# Simply renders the variation ajax partial
	def add_variation_ajax
	  @variation = Variation.new
	  # Set random ID so that we can reference things from JS...
	  @variation.id = Time.now.to_i
	  render(:update) { |page| page.insert_html :bottom, 'variation_container', :partial => 'variation' }
  end
	
	# Called for actually removing a variation if found, or just returns
	# nothing.
	#
	# This gets called for removing actual variations, and removing variations
	# that haven't been saved yet.
	#
	def remove_variation_ajax
	  @v = Variation.find(:first, :conditions => ["id = ?", params[:id]])
	  @v.destroy if @v
	  render :nothing => 'true'
  end
	
	# Updates image rank for a product.
	#
	def update_image_rank_ajax
    logger.info params.inspect
    params[:image_list].each_index do |i|
      pi = ProductImage.find(
        :first,
        :conditions => ["image_id = ? AND product_id = ?", params[:image_list][i], params[:id]]
      )
      if pi
        pi.rank = i
        pi.save
      end
    end
    # RJS to flash the sort divvy
    render(:update) { |page| page.call "highlightItem", "image_list" }
  end

  # Removes an image from the system
  def remove_image_ajax
    Image.find_by_id(params[:id]).destroy()
    render :nothing => true
  end
  
  # Removes a download
  def remove_download_ajax
    Download.find_by_id(params[:id]).destroy()
    render :nothing => true
  end
end

private
  # Sets the tags instance variable
  #
  def set_tags
    @tags = Tag.find_ordered_parents
  end