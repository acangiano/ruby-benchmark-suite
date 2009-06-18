class Admin::SectionsController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

	# List manages addition/deletion of items through ajax
  def list
    @title = 'Manage Sections'
    @sections = Section.find_ordered_parents()
    
    if params[:id]
      @parent_section = Section.find_by_name(params[:id])
      # If given faulty parent section, redirect back to list with no ID
      # ...and show an error.
      if !@parent_section
        flash.now[:notice] = "Sorry, we couldn't find the section you were looking for"
        render and return
      end
      @parent_section_id = @parent_section.id
      @sections = @parent_section.children
    end
  end
  
  # AJAX
  #
  def update_rank
    params[:section_list].each_index do |i|
      section = Section.find(params[:section_list][i])
      if section
        section.rank = i
        section.save
      end
    end
    render :nothing => true
  end

	# Creation returns text to the page which is inserted as a partial.
	#
  def create
    @section = Section.new(params[:section])
    if params[:id]
      @section.parent_id = params[:id]
    end
    if @section.save
      render(:partial => 'section_list_row', :locals => {:section_list_row => @section})
    else
      render :text => ""
    end
  end

	# Called via AJAX
  def update
    @section = Section.find(params[:id])
		@section.name = params[:name]
    if !@section.save
      render(:update) do |page| 
        page.alert "Something went wrong saving your section.\n\nRemember, section names have to be unique."
      end
    else
      render(:update) do |page| 
        page.replace "section_#{@section.id}", :partial => 'section_list_row', :locals => { :section_list_row => @section }
        page.sortable(
    			'section_list',
    			:url => { :action => 'update_section_rank' }
    		)
      end
    end
  end

	# Called via AJAX. 
  def destroy
    @section = Section.find(params[:id])
		section_id = @section.id
		@section.destroy
		# Render nothing to denote success
    render :text => ""
  end
end
