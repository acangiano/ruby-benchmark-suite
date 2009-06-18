class Admin::RolesController < Admin::BaseController
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    @title = 'Role List'
    @roles = Role.find(:all)
  end

  def new
		@title = "Creating new Role"
    @role = Role.new(params[:role])
		@rights = Right.find(:all, :order => 'name ASC')
    if request.post? and @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to :action => 'list' and return
    end
		render :action => 'edit'
  end

  def edit
		@title = "Editing Role"
    @role = Role.find(params[:id])
    @role.attributes = params["role"]
		
		@rights = Right.find(:all, :order => 'name ASC')
		
		# Update user
    if request.post? and @role.save
      flash[:notice] = 'Role was successfully updated.'
      redirect_to :action => 'list'
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
end
