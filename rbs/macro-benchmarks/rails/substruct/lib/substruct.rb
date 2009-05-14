#  Copyright (c) 2006 Subimage Interactive - http://www.subimage.com
require_dependency 'substruct/login_system.rb'

require 'patch_attachment_fu'

module Substruct
  # Should we use live rate calculation via FedEx?
  mattr_accessor :use_live_rate_calculation
  self.use_live_rate_calculation = false

  # Override SSL production mode?
  # If set to true the cart and checkout are accessed via HTTP not HTTPS
  # regardless of the mode that the server is run in.
  # 
  # This is useful for me on the demo site where I don't want
  # to set up a SSL cert.
  mattr_accessor :override_ssl_production_mode
  self.override_ssl_production_mode = false

	# For alternating row colors...
	def alternate(str1 = "odd", str2 = "even")
		 @alternate_odd_even_state = true if @alternate_odd_even_state.nil?
		 @alternate_odd_even_state = !@alternate_odd_even_state
		 @alternate_odd_even_state ? str2 : str1
	end

	# For linking to sections (using subdirs)
  def link_to_section(label, options = {})
		$ctrlop = options[:controller]
    if request.request_uri == options[:controller]
      link_to(label, options, { :class => "active"})
    else
      link_to(label, options)
    end
  end

	# Override of link_to that uses permission check
	#
	# Return nothing if the current user doesn't have access to the object.
=begin

RIGHT NOW THIS HAS UNUSABLE PERFORMANCE.
LOOKING INTO OTHER OPTIONS!!!

	def link_to(label, options = {}, html_options = nil, *parameters_for_method_reference)
		has_access = true
		# Right now permissions only apply to the admin side!
		url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
		if url.include?('/admin') then 
			# Get string positions of all items
			admin_pos = url.index('/admin')
			controller_pos = url.index('/', admin_pos)+1
			action_pos = url.index('/', controller_pos)+1 if controller_pos
			#
			if action_pos then
				action_end_pos = url.index('/', action_pos) || url.length
				controller_end_pos = action_pos-1
			else
				controller_end_pos = url.length-1
			end
			# Figure out what controller / action we're linking to
			controller = url[admin_pos, controller_end_pos] if controller_pos
			action = url[action_pos, action_end_pos] if action_pos
			# 
			has_access = check_authorization(controller, action, false)
		end
		link_to(label, options, html_options, *parameters_for_method_reference) if has_access
	end
=end

	# Gets a link to checkout
	# If we're in production mode we go to the HTTPS server
	#
	def get_link_to_checkout
		# For things like the demo site I need to disable SSL
		if (Substruct.override_ssl_production_mode == true) then
			return "/store/checkout"
		elsif ENV['RAILS_ENV'] == "production" then
      return "https://#{request.host}/store/checkout"
    else
      return "/store/checkout"
    end
	end

  # Generates a navigation string from an array list
  def generate_navigation(options, currently_viewing=nil, action='list')
    list = "<ul class=\"navigation secondary\">\n"

    options.each do |item|
      if currently_viewing == item then
        list << "<li class=\"active\">#{item}</li>"
      else
        list << "<li>"
        list << link_to(item, :action => action, :key => item)
        list << "</li>"
      end
    end

    return list << "</ul>"
  end

  # Truncates to the nearest word
  def truncate_words(text, length = 30, end_string = '')
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  #
  # $Id: sanitize.rb 3 2005-04-05 12:51:14Z dwight $
  #
  # Copyright (c) 2005 Dwight Shih
  # A derived work of the Perl version:
  # Copyright (c) 2002 Brad Choate, bradchoate.com
  #
  # Permission is hereby granted, free of charge, to
  # any person obtaining a copy of this software and
  # associated documentation files (the "Software"), to
  # deal in the Software without restriction, including
  # without limitation the rights to use, copy, modify,
  # merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to
  # whom the Software is furnished to do so, subject to
  # the following conditions:
  #
  # The above copyright notice and this permission
  # notice shall be included in all copies or
  # substantial portions of the Software.
  #
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY
  # OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
  # LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND
  # NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
  # COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
  # OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  # CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
  # OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  # OTHER DEALINGS IN THE SOFTWARE.
  #
  def sanitize_html( html, okTags='a href, b, br, i, p, strong, em, table, tr, td, tbody, th, ul, ol, li, img src, img, h1, h2, h3, h4' )
    # no closing tag necessary for these
    soloTags = ["br","hr"]

    # Build hash of allowed tags with allowed attributes
    tags = okTags.downcase().split(',').collect!{ |s| s.split(' ') }
    allowed = Hash.new
    tags.each do |s|
      key = s.shift
      allowed[key] = s
    end

    # Analyze all <> elements
    stack = Array.new
    result = html.gsub( /(<.*?>)/m ) do | element |
      if element =~ /\A<\/(\w+)/ then
        # </tag>
        tag = $1.downcase
        if allowed.include?(tag) && stack.include?(tag) then
          # If allowed and on the stack
          # Then pop down the stack
          top = stack.pop
          out = "</#{top}>"
          until top == tag do
            top = stack.pop
            out << "</#{top}>"
          end
          out
        end
      elsif element =~ /\A<(\w+)\s*\/>/
        # <tag />
        tag = $1.downcase
        if allowed.include?(tag) then
          "<#{tag} />"
        end
      elsif element =~ /\A<(\w+)/ then
        # <tag ...>
        tag = $1.downcase
        if allowed.include?(tag) then
          if ! soloTags.include?(tag) then
            stack.push(tag)
          end
          if allowed[tag].length == 0 then
            # no allowed attributes
            "<#{tag}>"
          else
            # allowed attributes?
            out = "<#{tag}"
            while ( $' =~ /(\w+)=("[^"]+")/ )
              attr = $1.downcase
              valu = $2
              if allowed[tag].include?(attr) then
                out << " #{attr}=#{valu}"
              end
            end
            out << ">"
          end
        end
      end
    end

    # eat up unmatched leading >
    while result.sub!(/\A([^<]*)>/m) { $1 } do end

    # eat up unmatched trailing <
    while result.sub!(/<([^>]*)\Z/m) { $1 } do end

    # clean up the stack
    if stack.length > 0 then
      result << "</#{stack.reverse.join('></')}>"
    end

    result
  end

  # Returns markdown formatted content
  def get_markdown(content)
    new_content = RedCloth.new(content).to_html
  end

  # Gets a markdown formatted snippet of content, truncated.
  def get_markdown_snippet(content, length=100)
    rc = RedCloth.new(content).to_html
    cut_content = truncate_words(rc, length)
    new_content = sanitize_html(cut_content)
  end

end
