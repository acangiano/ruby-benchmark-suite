dest = File.join(RAILS_ROOT, "script/performance/request")
FileUtils.cp File.join(File.dirname(__FILE__), 'bin/request'), dest
FileUtils.chmod(0755, dest)
