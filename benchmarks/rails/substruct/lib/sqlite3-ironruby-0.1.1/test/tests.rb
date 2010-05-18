Dir.chdir File.dirname( __FILE__ )
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
p $LOAD_PATH

Dir["**/tc_*.rb"].each { |file| load file }
