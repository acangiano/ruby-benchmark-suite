# A role is a collection of rights.
#
class Role < ActiveRecord::Base 
	has_and_belongs_to_many :users 
	has_and_belongs_to_many :rights, :order => 'name ASC'
	
  validates_presence_of :name

  # Sets rights by list of id's passed in
	def right_ids=(id_list)
		self.rights.clear
		for id in id_list
			next if id.empty?
			right = Right.find(id)
			self.rights << right if right
		end
	end
end