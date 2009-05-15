# Represents a downloadable file linked to a product.
# Added as a subclass of 'UserUpload' because we already
# have support for uploading / managing files.
#
# Customers may purchase digital downloads (photos, mp3s, whatever)
# and will receive a download link upon finishing their order. 
#
# They will also get this link in their email receipt generated
# by the system.
#
class Download < UserUpload
  has_many :product_downloads, :dependent => :destroy
  has_one :product, :through => :product_downloads
  
  MAX_SIZE = 20.megabyte
  
  has_attachment(
    :storage => :file_system,
    :max_size => MAX_SIZE,
    :thumbnails => { :thumb => '50x50>', :small => '200x200' },
    :processor => 'MiniMagick',
    :path_prefix => 'public/system/'
  )

  validates_as_attachment
end