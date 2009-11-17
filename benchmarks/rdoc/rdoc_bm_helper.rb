require 'fileutils'

class Object

  def go folder, extra_params = []
    # cleanup just in case
    if File.exist? 'doc'
      FileUtils.rm_rf 'doc'
    end  # run rdoc against itself
    $:.unshift 'rdp-rdoc-2.4.6/lib' # use local copy of rdoc

    ARGV.clear
    for command in extra_params + ["--op=doc", "--debug", folder]
      ARGV.push command
    end
    load "rdp-rdoc-2.4.6/bin/rdoc"
    FileUtils.rm_rf 'doc'
  end
end
