# currently we need a lotta gems
# require them up front just in case they're not installed
$:.unshift '19_compat' if RUBY_VERSION >= '1.9'
require 'rubygems'

for gem in ["RedCloth", "fastercsv", "mime/types", "mini_magick", "ezcrypto"] do
 require gem
end

startup_path = File.join(Dir.pwd, 'substruct', 'config', 'boot') # avoid a weird
# File.dirname bug in older versions of 1.8.7, and in 1.8.6, by computing this before chdir.
# http://redmine.ruby-lang.org/issues/show/1226

ENV['RAILS_ENV'] = 'production'

Dir.chdir 'substruct'
require startup_path

require 'config/environment'
require 'application_controller'

begin
 Product.first # raising here means the DB doesn't exist
 puts 'database appears initialized'
rescue Exception
     puts 'recreating database'
     require 'rake'
     require 'rake/testtask'
     require 'rake/rdoctask'
     require 'tasks/rails'
     Rake::Task['db:create'].invoke
     Rake::Task['substruct:db:bootstrap'].invoke
end
Product.destroy_all
Variation.destroy_all

