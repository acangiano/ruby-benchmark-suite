require 'rdoc'

##
# We contain the common stuff for contexts (which are containers) and other
# elements (methods, attributes and so on)

class RDoc::CodeObject

  ##
  # Our comment

  attr_reader :comment

  ##
  # Do we document our children?

  attr_reader :document_children

  ##
  # Do we document ourselves?

  attr_reader :document_self

  ##
  # Are we done documenting (ie, did we come across a :enddoc:)?

  attr_accessor :done_documenting

  ##
  # Force documentation of this CodeObject

  attr_accessor :force_documentation

  ##
  # Our parent CodeObject

  attr_accessor :parent

  ##
  # Which section are we in

  attr_accessor :section

  ##
  # We are the model of the code, but we know that at some point we will be
  # worked on by viewers. By implementing the Viewable protocol, viewers can
  # associated themselves with these objects.

  attr_accessor :viewer

  ##
  # There's a wee trick we pull. Comment blocks can have directives that
  # override the stuff we extract during the parse. So, we have a special
  # class method, attr_overridable, that lets code objects list those
  # directives. When a comment is assigned, we then extract out any matching
  # directives and update our object

  def self.attr_overridable(name, *aliases)
    @overridables ||= {}

    attr_accessor name

    aliases.unshift name

    aliases.each do |directive_name|
      @overridables[directive_name.to_s] = name
    end
  end

  ##
  # Creates a new CodeObject that will document itself and its children

  def initialize
    @comment = nil
    @document_children = true
    @document_self = true
    @done_documenting = false
    @force_documentation = false
    @parent = nil
  end

  ##
  # Replaces our comment with +comment+, unless it is empty.

  def comment=(comment)
    @comment = comment unless comment.empty?
  end

  ##
  # Enables or disables documentation of this CodeObject's children.  Calls
  # remove_classes_and_modules when disabling.

  def document_children=(document_children)
    @document_children = document_children
    remove_classes_and_modules unless document_children
  end

  ##
  # Enables or disables documentation of this CodeObject.  Calls
  # remove_methods_etc when disabling.

  def document_self=(document_self)
    @document_self = document_self
    remove_methods_etc unless document_self
  end

  ##
  # File name of our parent

  def parent_file_name
    @parent ? @parent.base_name : '(unknown)'
  end

  ##
  # Name of our parent

  def parent_name
    @parent ? @parent.full_name : '(unknown)'
  end

  ##
  # Callback called upon disabling documentation of children.  See
  # #document_children=

  def remove_classes_and_modules
  end

  ##
  # Callback called upon disabling documentation of ourself.  See
  # #document_self=

  def remove_methods_etc
  end

  ##
  # Enable capture of documentation

  def start_doc
    @document_self = true
    @document_children = true
  end

  ##
  # Disable capture of documentation

  def stop_doc
    @document_self = false
    @document_children = false
  end

end

