# A right is a controller resource that determines
# access.
#
# Rights are assigned to roles, roles to users.
#
# Rights consist of a controller name and an action list.
# This action list can be either '*' for access to all actions
# or a CSV list of actions.
#
class Right < ActiveRecord::Base 
	has_and_belongs_to_many :roles 
end