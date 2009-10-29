require 'fileutils'

class Object


  def go extra_params

    # cleanup
    if File.exist? 'doc'
      FileUtils.rm_rf 'doc'
    end  # run rdoc against itself
    $:.unshift 'rdoc-2.4.3/lib' # use local copy of rdoc
    ARGV.clear
    for command in extra_params + ["--op=doc", "--debug"]
      ARGV.push command
    end
    load "rdoc-2.4.3/bin/rdoc"
    FileUtils.rm_rf 'doc'
  end
end
