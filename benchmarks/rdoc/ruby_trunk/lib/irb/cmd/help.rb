#
#   help.rb - helper using ri
#   	$Release Version: 0.9.6$
#   	$Revision: 25189 $
#
# --
#
#
#

require 'rdoc/ri/driver'
require 'rdoc/ri/util'

require "irb/cmd/nop.rb"

module IRB
  module ExtendCommand
    class Help<Nop
      begin
        Ri = RDoc::RI::Driver.new
      rescue SystemExit
      else
        def execute(*names)
          names.each do |name|
            begin
              Ri.get_info_for(name.to_s)
            rescue RDoc::RI::Error
              puts $!.message
            end
          end
          nil
        end
      end
    end
  end
end
