namespace :substruct do
      
  SUBSTRUCT_DATA_DUMP_MODELS = [
    'ContentNode', 'Country', 'Preference', 'OrderShippingType', 
    'OrderShippingWeight', 'OrderStatusCode', 'Right', 'Role', 'Tag', 'User'
  ]
  
  SUBSTRUCT_BOOTSTRAP_PATH = '/db/bootstrap'
  
  # MAINTENANCE ===============================================================
  
  desc %q\
  Hourly maintenance task that should be run on your Substruct site.
  Does some housekeeping so the DB is in order.
  Remember to pass it the proper RAILS_ENV if running from cron.
  \
  task :maintain => :environment do
    puts "Updating country order counts..."
    countries = Country.find(:all)
    countries.each { |c|
      sql = "SELECT COUNT(*) "
      sql << "FROM order_addresses "
      sql << "WHERE country_id = ?"
      c.number_of_orders = ActiveRecord::Base.count_by_sql([sql, c.id])
      c.save
    }

    puts "Updating product costs..."
    orders = Order.find(:all, :conditions => "product_cost = 0")
    orders.each { |order|
      order.product_cost = order.line_items_total
      order.save
    }

    puts "Removing crusty sessions..."
    stale = Session.find(:all, :conditions => ["updated_at <= ?", Time.now - Session::SESSION_TIMEOUT])
    stale.each { |s| s.destroy }
  end

  REQUIRED_GEMS = %w(RedCloth fastercsv mime-types mini_magick ezcrypto)
  
  # DATABASE ==================================================================
  desc "Install gems substruct relies on -- #{REQUIRED_GEMS.inspect}"
  task :install_substruct_required_gems do |task_args|
    REQUIRED_GEMS.each do |gem|
      print "installing #{gem}"
      system("gem install #{gem}")
   end
  end

  namespace :db do
    
    desc %q\
    Initializes Substruct database passed in RAILS_ENV and preps for use.
    Will drop / re-create / re-load authority data.
    BE CAREFUL THIS WILL DESTROY YOUR DATA IF USED INCORRECTLY.
    \
    task :bootstrap do |task_args|
      
      # Check requirements
      require 'rubygems' unless Object.const_defined?(:Gem)
      REQUIRED_GEMS.each do |gem_name|
        check_installed_gem(gem_name)
      end
      
      mkdir_p File.join(RAILS_ROOT, 'log')
      
      puts "Checking requirements..."
    
      # Check for net/ssl
      begin
        require 'openssl'
      rescue
        puts
        puts '=' * 80
        puts
        puts "!!! OPENSSL LOAD ERROR"
        puts
        puts "Your machine appears to be missing the openssl library."
        puts
        puts "On Debian/Ubuntu linux boxes this is not included with the "
        puts "default Ruby installer. If you are running one of these systems"
        puts "it's as easy as typing 'apt-get install libopenssl-ruby1.8'."
        puts
        puts "You must install openssl before continuing."
        puts
        raise
      end
    
      puts "Initializing database..."
      
      # Move our schema file into place so we can load it.
      schema_file = 'schema.rb'
      FileUtils.cp(schema_file, File.join(RAILS_ROOT, 'db'))
    
      %w(
        environment 
        db:drop
        db:create
        db:schema:load
        substruct:db:load_authority_data
        tmp:create
      ).each { |t| Rake::Task[t].execute task_args}
      
      
      # We have to set the proper plugin schema migration,
      # because loading from bootstrap doesn't do it.
      #
      # Grab current schema version from the migration scripts.
      schema_files = Dir.glob(File.join(RAILS_ROOT, '/db/migrate', '*'))
      schema_version = File.basename(schema_files.sort.last).to_i
      
      puts '=' * 80
      puts
      puts "Thanks for trying Substruct #{Substruct::Version::STRING}"
      puts
      puts "Now you can start the application with 'script/server' "
      puts "visit: http://localhost:3000/admin, and log in with admin / admin."
      puts
      puts "For help, visit the following:"
      puts "  Official Substruct Sites "
      puts "    - http://substruct.subimage.com"
      puts "    - http://code.google.com/p/substruct/"
      puts "  Substruct Google Group - http://groups.google.com/group/substruct"
      puts
      puts "- Subimage LLC - http://www.subimage.com"
      puts 

    end # bootstrap
    
    desc %q\
    Dump authority data to YML files.
    ...Also moves dumped files to the proper directory required for an import later on.
    You don't need this unless you're prepping an official Substruct release.
    \
    task :dump_authority_data => :environment do |task_args|

      bootstrap_fixture_path = File.join(RAILS_ROOT, SUBSTRUCT_BOOTSTRAP_PATH)
      fixture_dump_path = File.join(RAILS_ROOT, 'test/fixtures')
      
      FileUtils.rm Dir.glob(File.join(fixture_dump_path, "*.yml"))
      
      # Dump
      puts "Dumping data..."
      SUBSTRUCT_DATA_DUMP_MODELS.each do |model_name|
        ENV['MODEL'] = model_name
        Rake::Task['db:fixtures:dump'].execute task_args
      end

      puts "Removing old fixture files..."
      FileUtils.rm Dir.glob(File.join(bootstrap_fixture_path, "*.yml"))
      puts "Moving fixture files to the proper location..."
      FileUtils.mv(Dir.glob(File.join(fixture_dump_path, "*.yml")), bootstrap_fixture_path)
      
    end
  
      
    desc %q\
    Loads baseline data needed for Substruct to operate.
    Delete records & load initial database fixtures (substruct/db/bootstrap/*.yml) into the current environment's database.
    \
    task :load_authority_data => :environment do
      require 'active_record/fixtures'
      puts "Clearing previous data..."
      SUBSTRUCT_DATA_DUMP_MODELS.each do |model|
        model.constantize.destroy_all
      end
      puts "Removing all sessions..."
      Session.destroy_all
      puts "Loading default data..."
      bootstrap_fixture_path = File.join(RAILS_ROOT, SUBSTRUCT_BOOTSTRAP_PATH)
      Dir.glob(File.join(bootstrap_fixture_path, '*.{yml,csv}')).each do |file|
        Fixtures.create_fixtures(bootstrap_fixture_path, File.basename(file, '.*'))
      end
      puts "...done."
    end
    
  end # db namespace
  
  # Packaging & release =======================================================
  
  namespace :release do
  
    desc %q\
    Packages a gzip release tagged by VERSION.
    Makes new Rails site, exports the stuff necessary, and gzips the badboy.
    Great for n00bz who can't install Rails apps.
    No more bitching about incorrect versions or dependencies!
    \
    task :package => :environment do
      version = ENV['VERSION']
      raise "Please specify a Substruct VERSION" if version.nil?
      tag = "rel_#{version}"
      release_name = "substruct_#{tag.gsub('.', '-')}"
      tmp_dir = File.join(RAILS_ROOT, 'tmp', release_name)
      # clean up any tmp releases
      FileUtils.rm_rf(Dir.glob(File.join(tmp_dir, '*.gz')))
      FileUtils.rm_rf(tmp_dir)
      FileUtils.mkdir_p(tmp_dir)
      Dir.chdir(tmp_dir)
      
      puts "Making Substruct #{version} release here: #{tmp_dir}"
      `rails .`
      
      
      puts "Exporting Substruct release from svn (#{tag})...\nThis might take a minute..."
      FileUtils.rm_rf(File.join(tmp_dir, 'vendor'))
      puts `svn export http://substruct.googlecode.com/svn/tags/#{tag} vendor`
      
      # Crazy shit we need to do in order to make this proper.
      # Better here than having people do it via instructions on the site!
      #
      puts "Copying appropriate files..."
      ss_dir = File.join(tmp_dir, '')      
      # copy from ss config dir into real config
      config_dir = File.join(tmp_dir, 'config')
      FileUtils.cp(File.join(ss_dir, 'config', 'environment.rb'), config_dir)
      FileUtils.cp(File.join(ss_dir, 'config', 'database.yml'), config_dir)
      
      # application.rb
      # necessary to include substruct engine before filters
      app_rb = File.join(ss_dir, 'config', 'application.rb.example')
      FileUtils.cp(app_rb, File.join(tmp_dir, 'app', 'controllers', 'application.rb'))

      # Insert standard substruct routes into default routes.rb
      routes = File.read(File.join(config_dir, 'routes.rb'))
      File.open(File.join(config_dir, 'routes.rb'), 'wb') { |f| f.write(routes.to_a.insert(1, "  map.from_plugin :substruct\n\n")) }
      
      # touch loading.html - necessary for submodal
      FileUtils.touch(File.join(tmp_dir, 'public', 'loading.html'))
      
      # remove index.html so people don't get stupid "welcome to rails" page
      FileUtils.rm(File.join(tmp_dir, 'public', 'index.html'))
      
      # rm application_helper so it'll use the one in substruct dir
      # ...might be better to copy?
      FileUtils.rm(File.join(tmp_dir, 'app/helpers', 'application_helper.rb'))
      
      Dir.chdir('..')
      puts "Tar and feathering..."
      rel_archive = "#{release_name}.tar.gz"
      `tar -czf #{rel_archive} #{release_name}`
      
      puts "Removing temp dir..."
      FileUtils.rm_rf(release_name)
      
      # Doesn't seem to work...
      #puts "Uploading to Google Code..."
      #`googlecode-upload.py -s 'Substruct #{version}' -p 'substruct' --config-dir=#{File.join(RAILS_ROOT, 'vendor')} #{rel_archive}`
      
      puts "Done."
    end
    
    desc %q\
    Tags a release using the version string from Substruct::Version::STRING
    \
    task :tag => :environment do
      version = ENV['VERSION'] || Substruct::Version::STRING
      puts "Tagging for version: #{version}"
      puts `svn copy vendor ../tags/rel_#{version}`
    end
  
  end # Packaging & release namespace
  

  # Testing and coverage =======================================================

  namespace :test do
    namespace :coverage do
      desc %q\
      Clean a previous test coverage report generated by rcov.
      \
      task :clean do
        puts "Deleting any previous coverage report generated..."
        rm_rf "\"#{RAILS_ROOT}/test/coverage/plugins/substruct/all\""
      end
    end
  
    desc %q\
    Measure test coverage using rcov.
    It runs all tests, unit, functional and integration, ignoring anything that is outside the scope of the plugin.
    \
    task :coverage => ["test:coverage:clean"] do 
      # Check requirements.
      check_installed_gem("rcov")
      puts "Generating a test coverage report for all tests using rcov..."
      
      # Rcov don't give us an easy way to use it inside /vendor, so we need to
      # compose the exclusion regex ourselves.

      # These are the regular expressions that by default rcov uses, but /vendor
      # wasn't included.
      rcov_default_files_to_omit = '\A\/usr\/lib,\btc_[^.]*.rb,_test\.rb\z,\btest\/,\A\/usr\/lib\/ruby\/gems\/1\.8\/gems\/rcov\-0\.8\.1\.2\.0\/lib\/rcov\/report\.rb\z'
      # This is the regexp that represents the --rails option, but /vendor
      # wasn't included.
      rcov_rails_regexp = '\bconfig\/,\benvironment\/'
      # This is what we don't want in reports that is inside /vendor.
      # It includes the frozen rails and all plugins except substruct.
      vendor_rails_regexp = '\bvendor\/rails\/'
      plugins_to_exclude_list = FileList['vendor/plugins/*'].pathmap("%f").exclude("substruct").to_s.gsub(%r{ }, '|')
      plugins_to_exclude_regex = '\bvendor\/plugins\/(' + "#{plugins_to_exclude_list}" + ')\/'
      # Others, usr/local/lib keeps appearing but its not being excluded anywhere else.
      others = '\A\/usr\/local\/lib'
      # Put it all together to compose the rcov options.
      exclusion_regexps = "#{others},#{rcov_default_files_to_omit},#{rcov_rails_regexp},#{vendor_rails_regexp},#{plugins_to_exclude_regex}"
      rcov_options = "-T --exclude-only \"#{exclusion_regexps}\""
      
      # Other params.
      rcov_output = "-o \"#{RAILS_ROOT}/test/coverage/plugins/substruct/all\""
      rcov_lib = "-Ilib:test"
      rcov_tests = FileList['/test/{unit,integration,functional}/**/*_test.rb']
      rcov_tests = rcov_tests.collect {|x| '"' + x + '"'}.to_s
      
      # Compose what will be run, and run it.
      rcov_cmd = "rcov #{rcov_output} #{rcov_lib} #{rcov_options} #{rcov_tests}"
      sh rcov_cmd
    end

  end # test namespace

  
  # Annotations =======================================================

  require "#{RAILS_ROOT}//lib/substruct_annotation_extractor.rb"
  
  desc "Enumerate all annotations"
  task :notes do
    SubstructAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO", :tag => true
  end
  
  namespace :notes do
    desc "Enumerate all OPTIMIZE annotations"
    task :optimize do
      SubstructAnnotationExtractor.enumerate "OPTIMIZE"
    end
  
    desc "Enumerate all FIXME annotations"
    task :fixme do
      SubstructAnnotationExtractor.enumerate "FIXME"
    end
  
    desc "Enumerate all TODO annotations"
    task :todo do
      SubstructAnnotationExtractor.enumerate "TODO"
    end
  end # notes namespace

end # substruct namespace

def check_installed_gem(gem_name)
  begin
    require gem_name.gsub('-', '/')
  rescue Gem::LoadError
    puts 
    puts '!!! GEM LOAD ERROR'
    puts 
    puts "You are missing the #{gem_name} gem."
    puts "Please install it before proceeding."
    puts
    raise
  end
end
