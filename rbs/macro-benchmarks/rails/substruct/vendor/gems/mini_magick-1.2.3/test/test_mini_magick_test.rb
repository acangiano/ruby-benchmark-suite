require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/mini_magick')

class ImageTest < Test::Unit::TestCase
  include MiniMagick
  
  CURRENT_DIR = File.dirname(File.expand_path(__FILE__)) + "/"

  SIMPLE_IMAGE_PATH = CURRENT_DIR + "simple.gif"
  TIFF_IMAGE_PATH = CURRENT_DIR + "burner.tiff"
  NOT_AN_IMAGE_PATH = CURRENT_DIR + "not_an_image.php"
  GIF_WITH_JPG_EXT = CURRENT_DIR + "actually_a_gif.jpg"
  EXIF_IMAGE_PATH = CURRENT_DIR + "trogdor.jpg"
  
  def test_image_from_blob
    File.open(SIMPLE_IMAGE_PATH, "rb") do |f|
      image = Image.from_blob(f.read)
    end
  end
  
  def test_image_from_file
    image = Image.from_file(SIMPLE_IMAGE_PATH)
  end
  
  def test_image_new
    image = Image.new(SIMPLE_IMAGE_PATH)
  end
  
  def test_image_write
    output_path = "output.gif"
    begin
      image = Image.new(SIMPLE_IMAGE_PATH)
      image.write output_path
      
      assert File.exists?(output_path)
    ensure
      File.delete output_path
    end
  end
  
  def test_not_an_image
    assert_raise(MiniMagickError) do
      image = Image.new(NOT_AN_IMAGE_PATH)
    end
  end
    
  def test_image_meta_info
    image = Image.new(SIMPLE_IMAGE_PATH)
    assert_equal 150, image[:width]
    assert_equal 55, image[:height]
    assert_match(/^gif$/i, image[:format])
  end

  def test_tiff
    image = Image.new(TIFF_IMAGE_PATH)    
    assert_equal "tiff", image[:format].downcase
    assert_equal 317, image[:width]
    assert_equal 275, image[:height]
  end
  
  def test_gif_with_jpg_format
    image = Image.new(GIF_WITH_JPG_EXT)    
    assert_equal "gif", image[:format].downcase
  end
  
  def test_image_resize
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    image.resize "20x30!"

    assert_equal 20, image[:width]
    assert_equal 30, image[:height]
    assert_match(/^gif$/i, image[:format])
  end 
  
  def test_image_resize_with_minimum
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    original_width, original_height = image[:width], image[:height]
    image.resize "#{original_width + 10}x#{original_height + 10}>"

    assert_equal original_width, image[:width]
    assert_equal original_height, image[:height]
  end
  
  def test_image_combine_options_resize_blur
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    image.combine_options do |c|
      c.resize "20x30!"
      c.blur 50
    end

    assert_equal 20, image[:width]
    assert_equal 30, image[:height]
    assert_match(/^gif$/i, image[:format])
  end
  
  def test_exif
    image = Image.from_file(EXIF_IMAGE_PATH)
    assert_equal('0220', image["exif:ExifVersion"])
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    assert_equal('', image["EXIF:ExifVersion"])
  end
  
  def test_original_at
    image = Image.from_file(EXIF_IMAGE_PATH)
    assert_equal(Time.local('2005', '2', '23', '23', '17', '24'), image[:original_at])
    image = Image.from_file(SIMPLE_IMAGE_PATH)
    assert_nil(image[:original_at])
  end
end 

class CommandBuilderTest < Test::Unit::TestCase
  include MiniMagick
  
  def test_basic
    c = CommandBuilder.new
    c.resize "30x40"
    assert_equal "-resize 30x40", c.args.join(" ")
  end
  
  def test_complicated
    c = CommandBuilder.new
    c.resize "30x40"
    c.input 1, 3, 4
    c.lingo "mome fingo"
    assert_equal "-resize 30x40 -input 1 3 4 -lingo mome fingo", c.args.join(" ")
  end
end
