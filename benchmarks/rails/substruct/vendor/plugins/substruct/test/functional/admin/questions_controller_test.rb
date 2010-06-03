$: << '.'
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::QuestionsControllerTest < ActionController::TestCase
  fixtures :rights, :roles, :users
  fixtures :questions


  # Test the index action.
  def test_should_show_index
    login_as :admin

    get :index
    assert_response :success
    assert_template 'list'
  end


  # Test the list action.
  def test_should_show_list
    login_as :admin

    get :list
    assert_response :success
    assert_template 'list'
    assert_equal assigns(:title), "Question List"
    assert_not_nil assigns(:questions)
  end


  # Test the show action.
  def test_should_show_show
    login_as :admin

    a_question = questions(:about_stuff)

    get :show, :id => a_question.id
    assert_response :success
    assert_template 'show'
    assert_equal assigns(:title), "Showing Question"
    assert_not_nil assigns(:question)
  end

  
  # Test the create action. Here we test if a new valid question will be saved.
  def test_should_save_new_question
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a question.
    post :create,
    :question => {
      :short_question => "Do you sell X?",
      :long_question => "Do you sell product X?",
      :answer => "Everything we sell is available at the store.",
      :email_address => "somebody@somewhere.com",
      :featured => "0",
      :rank => "",
      :times_viewed => "0"
    }
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :list
    
    # Verify that the question really is there.
    a_question = Question.find_by_short_question('Do you sell X?')
    assert_not_nil a_question
  end


  # Test the create action. Here we test if a new invalid question will NOT be
  # saved.
  def test_should_not_save_new_question
    login_as :admin

    # Call the new form.
    get :new
    assert_response :success
    assert_template 'new'
    
    # Post to it a promotion.
    post :create,
    :question => {
      :short_question => "",
      :long_question => "Do you sell product X?",
      :answer => "Everything we sell is available at the store.",
      :email_address => "somebody@somewhere.com",
      :featured => "0",
      :rank => "",
      :times_viewed => "0"
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'new'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#question_short_question"
  end


  # Change attributes from question.
  def test_should_save_existing_question
    login_as :admin
    
    a_question = questions(:about_stuff)

    # Call the edit form.
    get :edit, :id => a_question.id
    assert_response :success
    assert_template 'edit'

    # Post to it a question.
    post :update,
    :id => a_question.id,
    :question => {
      :short_question => "About The Stuff",
      :long_question => "I bought a cup of The Stuff and I'm feeling weird, what's happening? I'm feeling like there's something inside me.",
      :answer => "",
      :email_address => "somebody@somewhere.com",
      :featured => "0",
      :rank => "",
      :times_viewed => "0"
    }
    
    # If saved we should be redirected to list. 
    assert_response :redirect
    assert_redirected_to :action => :show
    
    # Verify that the change was made.
    a_question.reload
    assert_equal a_question.long_question, "I bought a cup of The Stuff and I'm feeling weird, what's happening? I'm feeling like there's something inside me."
  end


  # Change attributes from question making it invalid, it should NOT be saved.
  def test_should_not_save_existing_question
    login_as :admin
    
    a_question = questions(:about_stuff)

    # Call the edit form.
    get :edit, :id => a_question.id
    assert_response :success
    assert_template 'edit'

    # Post to it a question.
    post :update,
    :id => a_question.id,
    :question => {
      :short_question => "",
      :long_question => "I bought a cup of The Stuff and I'm feeling weird, what's happening? I'm feeling like there's something inside me.",
      :answer => "",
      :email_address => "somebody@somewhere.com",
      :featured => "0",
      :rank => "",
      :times_viewed => "0"
    }
    
    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to list action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'edit'

    # Here we assert that the proper fields was marked.
    assert_select "div.fieldWithErrors input#question_short_question"
  end


  # Test if we can remove questions.
  def test_should_remove_question
    login_as :admin

    a_question = questions(:about_stuff)

    # Post to it a question.
    post :destroy, :id => a_question.id

    assert_raise(ActiveRecord::RecordNotFound) {
      Question.find(a_question.id)
    }
  end


end
