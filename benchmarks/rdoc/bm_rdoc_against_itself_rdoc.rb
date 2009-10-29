require 'fileutils'
require './rdoc_bm_helper'
Bench.run [1] do |n|
  # run rdoc against itself
  go []
end
