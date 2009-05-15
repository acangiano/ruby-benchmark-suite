# executing this requires the mime-types gem to be installed
# sudo gem install mime-types
require 'mime/types'

class UserUploadSwitchToAttachmentFu < ActiveRecord::Migration

  def self.get_content_type(filename)
    mimes = MIME::Types.type_for(filename)
    mimes[0].content_type
  end

  def self.pad_id(id)
    result = id.to_s
    until result.length == 4
      result = '0' + result
    end
    result
  end

  def self.create_thumbnail(user_upload, thumb_type, old_prefix, new_dir)
    path = "#{old_prefix}/#{user_upload.id}/#{thumb_type}/#{user_upload.filename}"
    file = File.open(path, 'r')
    thumbnail = Image.new(:parent_id => user_upload.id,
                          :content_type => user_upload.content_type,
                          :filename => "#{user_upload.filename_without_ext}_#{thumb_type}.#{user_upload.extension}",
                          :thumbnail => thumb_type,
                          :size => file.read.size,
                          :height => 0,
                          :width => 0,
                          :type => 'Image')
    FileUtils.cp(path, "#{new_dir}/#{thumbnail.filename}")
    thumbnail.save!
    puts "Created #{thumb_type} user_upload db entry and copied the file to new spot for user_upload #{user_upload.id}"
  end

  def self.up
    remove_column :user_uploads, :description
    rename_column :user_uploads, :path, :filename
    add_column :user_uploads, :parent_id, :integer
    add_column :user_uploads, :content_type, :string
    add_column :user_uploads, :thumbnail, :string
    add_column :user_uploads, :size, :integer

    UserUpload.reset_column_information

    old_prefix = 'public/system/user_upload/path/'
    new_prefix = 'public/system/0000'
    
    FileUtils.mkdir_p(new_prefix) if Dir.glob(new_prefix).size == 0

    UserUpload.find(:all).each do |user_upload|
      path = File.join(RAILS_ROOT, old_prefix, user_upload.id.to_s, user_upload.filename)
      begin
        file = File.open(path, 'r')
      rescue
        puts $!
        puts "File not found on disk, deleting upload record..."
        user_upload.destroy
        next
      end

      # set content type
      user_upload.content_type = self.get_content_type(user_upload.filename)

      # set size
      data = file.read
      user_upload.size = data.size
      user_upload.save!
      puts "Saved user_upload #{user_upload.id}"

      # copy the file
      new_dir = "#{new_prefix}/#{self.pad_id(user_upload.id)}"
      FileUtils.mkdir(new_dir)
      FileUtils.cp(path, "#{new_dir}/#{user_upload.filename}")
      puts "Copied user_upload #{user_upload.id} to new spot."

      # create small and thumbs for images
      if user_upload[:type] == "Image"
        self.create_thumbnail(user_upload, 'thumb', old_prefix, new_dir)
        self.create_thumbnail(user_upload, 'small', old_prefix, new_dir)
      else
        # necessary since previously the type column for Assets was null, which means rails
        # single table inheritance wasn't occuring.  now it is, even though we don't really need it
        user_upload.type = 'Asset'
        user_upload.save!
      end

    end

  end

  def self.down
    # not easily reversible
  end

end