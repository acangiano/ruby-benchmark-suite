require './rdoc_bm_helper'
Bench.run [1] do |n|
  # run rdoc against itself with ri
  go ['--ri']
end
