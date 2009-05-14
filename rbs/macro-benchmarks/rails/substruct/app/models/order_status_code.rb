class OrderStatusCode < ActiveRecord::Base
  has_many :orders

  # Defines if we can edit this order or not based on the status code
  def is_editable?
    case self.id
      when 1..5
        return true
    else
      return false
    end
  end
end
