# Represents any type of user upload that's not an image.
#
class Asset < UserUpload
  
  MAX_SIZE = 10.megabyte

  has_attachment :storage => :file_system,
                 :max_size => MAX_SIZE,
                 :path_prefix => 'public/system/'

  validates_as_attachment

end