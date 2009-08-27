class SubstructDeprecated < StandardError; end

def substruct_deprecated(message=nil)
  $substruct_deprecated ||= {}
  deprecated_method = caller[0].gsub(/.*\`(.*)\'.*/,'\1')
  called_from = caller[1].gsub(%r{.*/\.\.\/(.*)$},'\1')
  
  warning = "Deprecation warning: #{deprecated_method} called from #{called_from}. #{message}"


  unless ($substruct_deprecated[warning])
    RAILS_DEFAULT_LOGGER.error "\n**** #{warning} ****\n"
    $substruct_deprecated[warning] = true
  end
  
  if ENV['RAILS_ENV'] == 'test'
    raise SubstructDeprecated, warning
  end
end

class Module 
  def substruct_deprecate(from_old_to_new)
    from_old_to_new.each do |old_name, new_name|
      define_method(old_name) do |*args|
        substruct_deprecated "Use #{new_name} instead of #{old_name}"
        send(new_name, *args)
      end
    end
  end
end