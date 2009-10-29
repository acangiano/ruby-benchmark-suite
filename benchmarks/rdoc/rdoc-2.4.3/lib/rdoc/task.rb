# Copyright (c) 2003, 2004 Jim Weirich, 2009 Eric Hodel
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
begin
  gem 'rdoc'
rescue Gem::LoadError
end

begin
  gem 'rake'
rescue Gem::LoadError
end

require 'rdoc'
require 'rake'
require 'rake/tasklib'

##
# Create a documentation task that will generate the RDoc files for a project.
#
# The RDoc::Task will create the following targets:
#
# [<b><em>rdoc</em></b>]
#   Main task for this RDoc task.
#
# [<b>:clobber_<em>rdoc</em></b>]
#   Delete all the rdoc files.  This target is automatically added to the main
#   clobber target.
#
# [<b>:re<em>rdoc</em></b>]
#   Rebuild the rdoc files from scratch, even if they are not out of date.
#
# Simple Example:
#
#   RDoc::Task.new do |rd|
#     rd.main = "README.rdoc"
#     rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
#   end
#
# The +rd+ object passed to the block is an RDoc::Task object. See the
# attributes list for the RDoc::Task class for available customization options.
#
# == Specifying different task names
#
# You may wish to give the task a different name, such as if you are
# generating two sets of documentation.  For instance, if you want to have a
# development set of documentation including private methods:
#
#   RDoc::Task.new :rdoc_dev do |rd|
#     rd.main = "README.doc"
#     rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
#     rd.options << "--all"
#   end
#
# The tasks would then be named :<em>rdoc_dev</em>,
# :clobber_<em>rdoc_dev</em>, and :re<em>rdoc_dev</em>.
#
# If you wish to have completely different task names, then pass a Hash as
# first argument. With the <tt>:rdoc</tt>, <tt>:clobber_rdoc</tt> and
# <tt>:rerdoc</tt> options, you can customize the task names to your liking.
#
# For example:
#
#   RDoc::Task.new(:rdoc => "rdoc", :clobber_rdoc => "rdoc:clean",
#                  :rerdoc => "rdoc:force")
#
# This will create the tasks <tt>:rdoc</tt>, <tt>:rdoc_clean</tt> and
# <tt>:rdoc:force</tt>.

class RDoc::Task < Rake::TaskLib

  ##
  # Name of the main, top level task.  (default is :rdoc)

  attr_accessor :name

  ##
  # Name of directory to receive the html output files. (default is "html")

  attr_accessor :rdoc_dir

  ##
  # Title of RDoc documentation. (defaults to rdoc's default)

  attr_accessor :title

  ##
  # Name of file to be used as the main, top level file of the RDoc. (default
  # is none)

  attr_accessor :main

  ##
  # Name of template to be used by rdoc. (defaults to rdoc's default)

  attr_accessor :template

  ##
  # List of files to be included in the rdoc generation. (default is [])

  attr_accessor :rdoc_files

  ##
  # Additional list of options to be passed rdoc.  (default is [])

  attr_accessor :options

  ##
  # Whether to run the rdoc process as an external shell (default is false)

  attr_accessor :external

  ##
  # Create an RDoc task with the given name. See the RDoc::Task class overview
  # for documentation.

  def initialize(name = :rdoc)  # :yield: self
    if name.is_a? Hash then
      invalid_options = name.keys.map { |k| k.to_sym } -
        [:rdoc, :clobber_rdoc, :rerdoc]

      unless invalid_options.empty? then
        raise ArgumentError, "invalid options: #{invalid_options.join(", ")}"
      end
    end

    @name = name
    @rdoc_files = Rake::FileList.new
    @rdoc_dir = 'html'
    @main = nil
    @title = nil
    @template = nil
    @external = false
    @options = []
    yield self if block_given?
    define
  end

  ##
  # Create the tasks defined by this task lib.

  def define
    if rdoc_task_name != "rdoc" then
      desc "Build the RDoc HTML Files"
    else
      desc "Build the #{rdoc_task_name} HTML Files"
    end
    task rdoc_task_name

    desc "Force a rebuild of the RDoc files"
    task rerdoc_task_name => [clobber_task_name, rdoc_task_name]

    desc "Remove RDoc products"
    task clobber_task_name do
      rm_r rdoc_dir rescue nil
    end

    task :clobber => [clobber_task_name]

    directory @rdoc_dir
    task rdoc_task_name => [rdoc_target]
    file rdoc_target => @rdoc_files + [Rake.application.rakefile] do
      rm_r @rdoc_dir rescue nil
      @before_running_rdoc.call if @before_running_rdoc
      args = option_list + @rdoc_files

      if @external then
        argstring = args.join(' ')
        sh %{ruby -Ivendor vendor/rd #{argstring}}
      else
        if Rake.application.options.trace then
          $stderr.puts "rdoc #{args.join ' '}"
        end
        require 'rdoc/rdoc'
        RDoc::RDoc.new.document(args)
      end
    end

    self
  end

  def option_list
    result = @options.dup
    result << "-o" << @rdoc_dir
    result << "--main" << quote(main) if main
    result << "--title" << quote(title) if title
    result << "-T" << quote(template) if template
    result
  end

  def quote(str)
    if @external
      "'#{str}'"
    else
      str
    end
  end

  def option_string
    option_list.join(' ')
  end

  ##
  # The block passed to this method will be called just before running the
  # RDoc generator. It is allowed to modify RDoc::Task attributes inside the
  # block.

  def before_running_rdoc(&block)
    @before_running_rdoc = block
  end

  private

  def rdoc_target
    "#{rdoc_dir}/index.html"
  end

  def rdoc_task_name
    case name
    when Hash
      (name[:rdoc] || "rdoc").to_s
    else
      name.to_s
    end
  end

  def clobber_task_name
    case name
    when Hash
      (name[:clobber_rdoc] || "clobber_rdoc").to_s
    else
      "clobber_#{name}"
    end
  end

  def rerdoc_task_name
    case name
    when Hash
      (name[:rerdoc] || "rerdoc").to_s
    else
      "re#{name}"
    end
  end

end

# :stopdoc:
module Rake

  ##
  # For backwards compatibility

  RDocTask = RDoc::Task

end
# :startdoc:

