class Question < ActiveRecord::Base
  # Validation
	validates_presence_of :short_question, :message => ERROR_EMPTY
  validates_presence_of :long_question, :message => ERROR_EMPTY
  validates_presence_of :email_address, :message => ERROR_EMPTY
end
