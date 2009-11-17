#
#   fork.rb -
#   	$Release Version: 0.9.6 $
#   	$Revision: 25189 $
#   	by Keiju ISHITSUKA(keiju@ruby-lang.org)
#
# --
#
#
#

@RCS_ID='-$Id: fork.rb 25189 2009-10-02 12:04:37Z akr $-'


module IRB
  module ExtendCommand
    class Fork<Nop
      def execute(&block)
	pid = send ExtendCommand.irb_original_method_name("fork")
	unless pid
	  class<<self
	    alias_method :exit, ExtendCommand.irb_original_method_name('exit')
	  end
	  if iterator?
	    begin
	      yield
	    ensure
	      exit
	    end
	  end
	end
	pid
      end
    end
  end
end


