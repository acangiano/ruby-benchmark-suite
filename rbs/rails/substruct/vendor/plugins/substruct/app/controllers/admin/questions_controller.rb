class Admin::QuestionsController < Admin::BaseController
  def index
    list
    render :action => 'list'
  end

  def list
    @title = 'Question List'
    @questions = Question.paginate(
      :order => '-rank DESC',
      :page => params[:page],
      :per_page => 30
    )
  end

  def show
    @title = "Showing Question"
    @question = Question.find(params[:id])
  end

  def new
    @title = "Creating new Question"
    @question = Question.new
  end

  def create
    @question = Question.new(params[:question])
    if @question.save
      flash[:notice] = 'Question was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @title = "Editing Question"
    @question = Question.find(params[:id])
  end

  def update
    @question = Question.find(params[:id])
    if @question.update_attributes(params[:question])
      flash[:notice] = 'Question was successfully updated.'
      redirect_to :action => 'show', :id => @question
    else
      render :action => 'edit'
    end
  end

  def destroy
    Question.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
