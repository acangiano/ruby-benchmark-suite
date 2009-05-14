class CountriesController < ApplicationController

	# Build a select list of countries.
  def select_list
    @select_name = params[:select_name]
    @selected = params[:selected]
    
    # Here we order the list by rank then by name, so, first lower ranks, then
    # equal ranks ordered by name. 
    @countries = Country.find(:all,
                              :conditions => ['is_obsolete != ?', 1],
                              :order => 'rank, name ASC')
  end

  # Build a select list of countries including those obsoleted.
  def complete_select_list
    @select_name = params[:select_name]
    @selected = params[:selected]
    
    # Here we order the list by rank then by name, so, first lower ranks, then
    # equal ranks ordered by name. 
    @countries = Country.find(:all,
                              :order => 'rank, name ASC')
    render :action => 'select_list'
  end
  
end
