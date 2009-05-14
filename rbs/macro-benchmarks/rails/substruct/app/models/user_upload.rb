# Represents a file uploaded by a user.
#
# Subclassed by Image and Asset
#
# Before a save, checks to set the type, based on file extension.
#
class UserUpload < ActiveRecord::Base
  IMAGE_EXTENSIONS = ['gif', 'jpg', 'jpeg', 'png', 'bmp']

  
  # Checks what type of file this is based on extension.
  #
  # If it's an image, we treat it differently and save
  # as an image type.
  #
  # No, we're not using anything fancy here, just the extension set.
  #

  before_save :downcase_extension
  def downcase_extension
    self.filename = "#{self.filename[0, self.filename.rindex('.')]}.#{self.extension.downcase}"
  end
  
  # Returns extension
  #
  def extension
    self.filename[self.filename.rindex('.') + 1, self.filename.size]
  end
  
  # Returns file name
  #
  def name
    self.filename
  end
  
  def relative_path
    #self.filename[self.filename.rindex('/public/system')+7, self.filename.size]
    self.filename
  end
  
  def filename_without_ext
    self.filename[0, self.filename.rindex('.')]
  end

  # use this to make a new user upload when you don't know whether it should
  # be an image or an asset.  Can't use UserUpload.new since it doesn't have uploaded_data.
  def self.init(file_data)
    if file_data.content_type.index('image')
      upload = Image.new
    else
      upload = Asset.new
    end
    upload.uploaded_data = file_data
    upload
  end

end