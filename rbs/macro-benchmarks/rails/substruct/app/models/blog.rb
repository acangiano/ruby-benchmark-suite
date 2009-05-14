# A post in the blog
#
class Blog < ContentNode
  #############################################################################
  # CLASS METHODS
  #############################################################################
  def self.find_latest
    find(
      :first,
      :order => "display_on DESC"
    )
  end
  
end