class Admin::TagsController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

	# List manages addition/deletion of items through ajax
  def list
    @title = 'Manage Tags'
    @tags = Tag.find_ordered_parents()
    
    if params[:id]
      @parent_tag = Tag.find_by_name(params[:id])
      # If given faulty parent tag, redirect back to list with no ID
      # ...and show an error.
      if !@parent_tag
        flash.now[:notice] = "Sorry, we couldn't find the tag you were looking for"
        render and return
      end
      @parent_tag_id = @parent_tag.id
      @tags = @parent_tag.children
    end
  end
  
  # AJAX
  #
  def update_tag_rank
    params[:tag_list].each_index do |i|
      tag = Tag.find(params[:tag_list][i])
      if tag
        tag.rank = i
        tag.save
      end
    end
    render :nothing => true
  end

	# Creation returns text to the page which is inserted as a partial.
	#
  def create
    @tag = Tag.new(params[:tag])
    if params[:id]
      @tag.parent_id = params[:id]
    end
    if @tag.save
      render(:partial => 'tag_list_row', :locals => {:tag_list_row => @tag})
    else
      render :text => ""
    end
  end

	# Called via AJAX
  def update
    @tag = Tag.find(params[:id])
		@tag.name = params[:name]
    if !@tag.save
      render(:update) do |page| 
        page.alert "Something went wrong saving your tag.\n\nRemember, tag names have to be unique."
      end
    else
      render(:update) do |page| 
        page.replace "tag_#{@tag.id}", :partial => 'tag_list_row', :locals => { :tag_list_row => @tag }
        page.sortable(
    			'tag_list',
    			:url => { :action => 'update_tag_rank' }
    		)
      end
    end
  end

	# Called via AJAX. 
  def destroy
    @tag = Tag.find(params[:id])
		tag_id = @tag.id
		@tag.destroy
		# Render nothing to denote success
    render :text => ""
  end
end
