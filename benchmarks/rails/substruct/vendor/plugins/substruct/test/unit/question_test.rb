$: << '.'
require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < ActiveSupport::TestCase
  fixtures :questions


  # Test if a valid question can be created with success.
  def test_should_create_question
    a_question = Question.new
    
    a_question.short_question = "Do you sell X?"
    a_question.long_question = "Do you sell product X?"
    a_question.answer = "Everything we sell is available at the store."
    a_question.email_address = "somebody@somewhere.com"
  
    assert a_question.save
  end


  # Test if a question can be found with success.
  def test_should_find_question
    a_question_id = questions(:about_stuff).id
    assert_nothing_raised {
      Question.find(a_question_id)
    }
  end


  # Test if a question can be updated with success.
  def test_should_update_question
    a_question = questions(:about_stuff)
    assert a_question.update_attributes(:long_question => "I bought a cup of The Stuff and I'm feeling weird, what's happening? I'm feeling like there's something inside me.")
  end


  # Test if a question can be destroyed with success.
  def test_should_destroy_question
    a_question = questions(:about_stuff)
    a_question.destroy
    assert_raise(ActiveRecord::RecordNotFound) {
      Question.find(a_question.id)
    }
  end


end
