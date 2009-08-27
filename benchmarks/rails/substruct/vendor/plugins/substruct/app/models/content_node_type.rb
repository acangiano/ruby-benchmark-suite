# THIS CLASS IS OBSOLETE.
#
# Only keeping it here to support migration #11 for the time being.
#
class ContentNodeType < ActiveRecord::Base
  has_many :content_nodes
end
