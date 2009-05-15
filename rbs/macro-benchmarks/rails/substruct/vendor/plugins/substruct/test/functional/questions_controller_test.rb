require File.dirname(__FILE__) + '/../test_helper'

class QuestionsControllerTest < ActionController::TestCase
  fixtures :questions
  

  # Test if the index will be shown.
  def test_should_show_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_equal assigns(:title), "Questions"
    
    # TODO: This action don't do anything.
  end


  # Test if the FAQ will be shown.
  def test_should_show_faq
    get :faq
    assert_response :success
    assert_template 'faq'
    assert_equal assigns(:title), "FAQ (Frequently Asked Questions)"
    assert_not_nil assigns(:questions)
    
    # Assert a question is there.
    assert_select "h2", :count => 1, :text => questions(:about_stuff).short_question
  end


  # Test if a question can be send.
  def test_should_send_a_question
    get :ask
    assert_response :success
    assert_template 'ask'
    
    # Post to it a question.
    post :send_question,
    :question => {
      :long_question => "Do you sell XYZ?",
      :email_address => "curious@nowhere.com"
    }

    # If accepted should just respond with success.
    assert_response :success
    assert_template 'send_question'
  end


  # Test if a question will NOT be send.
  def test_should_not_send_a_question
    get :ask
    assert_response :success
    assert_template 'ask'
    
    # Post to it a blank question.
    post :send_question,
    :question => {
      :long_question => "",
      :email_address => ""
    }

    # If not saved we will NOT receive a HTTP error status. As we will not be
    # redirected to edit action too. The same page will be rendered again with
    # error explanations.
    assert_response :success
    assert_template 'ask'
    
    # Here we assert that an error explanation was given and that the proper
    # fields was marked.
    assert_select "div.fieldWithErrors input#question_email_address"
    assert_select "div.fieldWithErrors textarea#question_long_question"
  end
  
  
end
