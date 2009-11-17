require 'rubygems/command'
require 'rubygems/local_remote_options'
require 'rubygems/version_option'
require 'rubygems/source_info_cache'

class Gem::Commands::FetchCommand < Gem::Command

  include Gem::LocalRemoteOptions
  include Gem::VersionOption

  def initialize
    super 'fetch', 'Download a gem and place it in the current directory'

    add_bulk_threshold_option
    add_proxy_option
    add_source_option

    add_version_option
    add_platform_option
  end

  def arguments # :nodoc:
    'GEMNAME       name of gem to download'
  end

  def defaults_str # :nodoc:
    "--version '#{Gem::Requirement.default}'"
  end

  def usage # :nodoc:
    "#{program_name} GEMNAME [GEMNAME ...]"
  end

  def execute
    version = options[:version] || Gem::Requirement.default
    all = Gem::Requirement.default

    gem_names = get_all_gem_names

    gem_names.each do |gem_name|
      dep = Gem::Dependency.new gem_name, version

      specs_and_sources = Gem::SpecFetcher.fetcher.fetch dep, all

      specs_and_sources.sort_by { |spec,| spec.version }

      spec, source_uri = specs_and_sources.last

      if spec.nil? then
        alert_error "Could not find #{gem_name} in any repository"
        next
      end

      path = Gem::RemoteFetcher.fetcher.download spec, source_uri
      FileUtils.mv path, "#{spec.full_name}.gem"

      say "Downloaded #{spec.full_name}"
    end
  end

end

