module Admin::BaseHelper
  def settings_field(field)
    case field.type
    when :string 
      %{<input type="text" value="#{config[field.name]}"  name="fields[#{field.name}]" />}
    when :bool
      %{<input type="checkbox" value="1" #{'checked="checked"' if config[field.name].to_i == 1} name="fields[#{field.name}]" /><input type="hidden" value="0" name="fields[#{field.name}]" />}
    when :int
      select_tag "fields[#{field.name}]", options_for_select(['none', (1..60).to_a].flatten, config[field.name].to_i)
    end
  end

  def render_flash
    output = []
    
    for key,value in @flash
      output << "<span class=\"#{key.downcase}\">#{value}</span>"
    end if @flash
      
    output.join("<br/>\n")
  end

  def render_tasks
     output = []

      for key,value in @tasks
   	  output << "<a href=\"#{value}\">#{key}</a>"
   	end if @tasks
   	  
   	output.join("<br/>\n")
  end
  
  def cancel(url = {:action => 'list'})
    "<input type=\"button\" value=\"Cancel\" style=\"width: auto;\" onclick=\"window.location.href = '#{url_for url}';\" />"
  end

  def save
    '<input type="submit" value="OK" class="primary" />'
  end

  def confirm_delete
   '<input type="submit" value="Delete" />'
  end

  def link_to_show(record)
    link_to image_tag('go'), :action => 'show', :id => record.id
  end  

  def link_to_edit(record)
    link_to image_tag('go'), :action => 'edit', :id => record.id
  end  

  def link_to_destroy(record)
    link_to image_tag('delete'), :action => 'destroy', :id => record.id
  end    

  def text_filter_options  
    text_filter_options = Array.new
    text_filter_options << [ 'None', 'none' ]
    text_filter_options << [ 'Textile', 'textile' ] if defined?(RedCloth)
    text_filter_options << [ 'Markdown', 'markdown' ] if defined?(BlueCloth)

    text_filter_options
  end
end
