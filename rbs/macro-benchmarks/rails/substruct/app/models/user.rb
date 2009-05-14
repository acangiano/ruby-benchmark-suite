require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
	has_and_belongs_to_many :roles, :order => 'name ASC'
	
	before_create :crypt_password
  before_update :crypt_unless_empty
	
	validates_uniqueness_of :login, :on => :create
  validates_length_of :login, :within => 3..40
	validates_presence_of :login
	
	def validate
	  if (self.new_record? || (!self.password.blank? && !self.password_confirmation.blank?))  
	    if (5 > self.password.length || 40 < self.password.length)
        errors.add(:password, " must be between 5 and 40 characters.")
      end
    end
    
    # check presence of password & matching if they both aren't blank
  	if (self.password != self.password_confirmation) then
  		errors.add(:password, " and confirmation don't match.")
  	end
  end
	
  @@salt = '20ac4d290c2293702c64b3b287ae5ea79b26a5c1'
  cattr_accessor :salt
	attr_accessor :password_confirmation

  # Authenticate a user. 
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    find(:first, :conditions => ["login = ? AND password = ?", login, sha1(pass)])
  end
  
  def self.authenticate?(login, pass)
    user = self.authenticate(login, pass)
    return false if user.nil?
    return true if user.login == login
    
    false
  end

	# Sets roles by list of id's passed in
	def role_ids=(id_list)
		logger.info("[ROLE IDS] #{id_list}")
		self.roles.clear
		for id in id_list
			next if id.empty?
			role = Role.find(id)
			self.roles << role if role
		end
	end


  protected
    # Apply SHA1 encryption to the supplied password. 
    # We will additionally surround the password with a salt 
    # for additional security. 
    def self.sha1(pass)
      Digest::SHA1.hexdigest("#{salt}--#{pass}--")
    end
      
    # Before saving the record to database we will crypt the password 
    # using SHA1. 
    # We never store the actual password in the DB.
    def crypt_password
  		write_attribute "password", self.class.sha1(password) unless self.password.empty?
    end
  
    # If the record is updated we will check if the password is empty.
    # If its empty we assume that the user didn't want to change his
    # password and just reset it to the old value.
    def crypt_unless_empty
  		if password.empty?
        user = self.class.find(self.id)
        self.password = user.password
      else
        write_attribute "password", self.class.sha1(password)
      end        
    end
  
end
