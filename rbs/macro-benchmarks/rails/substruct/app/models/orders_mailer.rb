class OrdersMailer < ActionMailer::Base
  helper :application

  def receipt(order, email_text)
    @subject = "Thank you for your order! (\##{order.order_number})"
    @body       = {:order => order, :email_text => email_text}
    @recipients = order.order_user.email_address
		@bcc        = Preference.find_by_name('mail_copy_to').value.split(',')
		@from       = Preference.find_by_name('mail_username').value
    @sent_on    = Time.now
    @headers    = {}
  end

  def reset_password(customer)
    @subject = "Password reset for #{Preference.find_by_name('store_name').value}"
    @body       = {:customer => customer}
    @recipients = customer.email_address
		@bcc        = Preference.find_by_name('mail_copy_to').value.split(',')
		@from       = Preference.find_by_name('mail_username').value
    @sent_on    = Time.now
    @headers    = {}
  end

  def failed(order)
    @subject = "An order has failed on the site"
    @body       = {:order => order}
		@recipients = Preference.find_by_name('mail_copy_to').value.split(',')
		@from       = Preference.find_by_name('mail_username').value
    @sent_on    = Time.now
    @headers    = {}
  end
  
end
